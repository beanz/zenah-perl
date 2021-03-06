package ZenAH::Engine;

# $Id$

=head1 NAME

ZenAH::Engine - Perl extension for the Zen Automated Home Engine

=head1 SYNOPSIS

  # Use ZenAH with all ZenAH::Engine::Plugin modules
  use ZenAH::Engine;
  my $zenah = ZenAH::Engine->new(@ARGV) or
                  die "Failed to create ZenAH::Engine\n";
  $zenah->main_loop();

=head1 DESCRIPTION

This is a module for the Zen Automated Home Engine.  It provides a
main loop and allows callbacks to be registered for events that
occur.  It also configures the L<ZenAH::Engine::Plugin> modules.

The event loop does not fork.  Therefore all callbacks must either be
short or they should fork.  For example, a callback that needed to
make an HTTP request could connect and send the request then add the
socket handle to receive the response to the engine event loop with a
suitable callback to handle the reply.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Template;
use Template::Context;
use Template::Document;
use Template::Parser;
use Template::Stash;

use List::Util;
use Time::HiRes;
use AnyEvent;
use xPL::Client;
use Module::Pluggable instantiate => 'new';
use ZenAH::DBIC;

require Exporter;

our @ISA = qw(xPL::Client);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

__PACKAGE__->make_collection(trigger =>
                             [qw/add_callback add_callback_count
                                 remove_callback remove_callback_count
                                 /],
                             action => [qw/callback callback_count/],
                             rule => [qw/mtime type template_document/],
                            );

# VMethods
$Template::Stash::LIST_OPS->{largest} = sub { List::Util::max(@{$_[0]}) };
$Template::Stash::LIST_OPS->{smallest} = sub { List::Util::min(@{$_[0]}) };
$Template::Stash::LIST_OPS->{sum} = sub { List::Util::sum(@{$_[0]}) };
$Template::Stash::LIST_OPS->{mean} = sub { List::Util::sum(@{$_[0]})/@{$_[0]} };
$Template::Stash::SCALAR_OPS->{int} = sub { int $_[0] };
$Template::Stash::SCALAR_OPS->{rand} = sub { rand $_[0] };

# Preloaded methods go here.

=head2 C<new(%params)>

The constructor creates a new L<ZenAH::Engine> object.  The
constructor takes a parameter hash as arguments.  Valid parameters in
the hash are inherited directly from the L<xPL::Client> constructor.

It returns a blessed reference when successful or undef otherwise.

=cut

sub new {
  my $pkg = shift;
  $pkg = ref($pkg) if (ref($pkg));

  my $self = $pkg->SUPER::new(vendor_id => 'bnz', device_id => 'zenah', @_);
  $self->{_db} = ZenAH::DBIC->schema();

  $self->init_triggers();
  $self->init_actions();
  $self->init_rules();
  $self->{_stash_zenah} = {};
  my $stash = Template::Stash->new(zenah => $self->{_stash_zenah});
  $self->{_template} =
    {
     context => Template::Context->new(STASH => $stash),
     parser => Template::Parser->new(),
     stash => $stash,
    };

  foreach my $plugin ($self->plugins(engine => $self, @_)) {
    my $name = ref $plugin;
    $name =~ s/.*:://;
    $self->{_plugin}->{$name} = $plugin;
  }

  $self->add_action(type => 'enable',
                    callback => sub { $self->action_enable_rule(@_) });
  $self->add_action(type => 'disable',
                    callback => sub { $self->action_disable_rule(@_) });
  $self->add_action(type => 'debug',
                    callback => sub { return $self->action_debug(@_) });

  $self->add_action(type => 'error',
                    callback => sub { return $self->action_error(@_) });

  $self->add_timer(id => 'rules_timer',
                   timeout => -120,
                   callback => sub { $self->read_rules(); 1; });

  $self->add_stash(rand => sub { rand $_[0] });

  $self->info("Done.\n\n");
  return $self;
}

=head2 C<read_rules()>

Method to (re)read the rule from the database.  It is called
automatically on startup and again every 120 seconds.

=cut

sub read_rules {
  my $self = shift;

  # TOFIX: ZenAH::CDBI::Rule->clear_object_index();

  my $rs = $self->{_db}->resultset('Rule')->search;

  while (my $rule = $rs->next) {
    $self->read_rule($rule);
  }

  return 1;
}

=head2 C<read_rule($rule)>

Method to (re)read a rule from the database.

=cut

sub read_rule {
  my $self = shift;
  my $rule = shift;

  unless ($rule->active) {
    if ($self->exists_rule($rule)) {
      my $old_type = $self->rule_type($rule);
      $self->trigger_remove_callback($old_type)->($rule);
      $self->remove_rule($rule);
      $self->info('Removed disabled rule: ', $rule->name, "\n");
    }
    return;
  }

  my $mtime = $rule->mtime;
  if ($self->exists_rule($rule)) {
    my $old_mtime = $self->rule_mtime($rule);
    return unless ($mtime > $old_mtime);
    my $old_type = $self->rule_type($rule);
    $self->trigger_remove_callback($old_type)->($rule);
    $self->remove_rule($rule);
    $self->info('Removed changed rule: ', $rule->name, "\n");
  }

  my $type = $rule->type;
  unless ($type) {
    warn "empty trigger type: ",$rule->name, "\n";
    return;
  }

  unless ($self->exists_trigger($type)) {
    warn "unknown trigger type: $type ",$rule->name, "\n";
    return;
  }
  my $trig = $rule->trig;

  my $parser = $self->{_template}->{parser};

  unless ($rule->action) {
    return $self->ouch('Action template is empty')
  }
  my $template = $parser->parse($rule->action) or
    return $self->ouch('Action template parse error: '.$parser->error);
  my $doc = Template::Document->new($template) or
    return $self->ouch('Action template doc error: '.
                       $Template::Document::ERROR);

  $self->info('Adding rule: ', $rule->name, "\n");

  eval { $self->trigger_add_callback($type)->($rule); };
  if ($@) {
    warn "Failed to add rule ", $rule->name, ": ", $@, "\n";
    return;
  }
  $self->add_rule($rule, { mtime => $rule->mtime(), type => $type,
                           template_document => $doc });

  return 1;
}

=head2 C<add_trigger(%params)>

This method is used by plugins to register a new type of trigger.
Valid parameters in the hash are:

=over

=item type

The name of the trigger type.

=item add_callback

The code reference to call when a new rule with this trigger type is
added to the database.  This is optional the default is an empty
sub.

=item remove_callback

The code reference to call when an old rule with this trigger type is
removed from the database.  This is optional the default is an empty
sub.

=back

=cut

sub add_trigger {
  my $self = shift;
  my %p = @_;
  exists $p{type} or $self->argh("requires 'type' argument");
  exists $p{add_callback} or $p{add_callback} = sub { 1 };
  exists $p{remove_callback} or $p{remove_callback} = sub { 1 };
  $p{add_callback_count} = 0;
  $p{remove_callback_count} = 0;
  $self->info("Adding trigger type: ", $p{type}, "\n");
  return $self->add_item('trigger', $p{type}, \%p);
}

=head2 C<add_action(%params)>

This method is used by plugins to register a new type of action.
Valid parameters in the hash are those used by :

=over

=item type

The name of the action type.

=item callback

The code reference to call when this action is invoked.

=back

=cut

sub add_action {
  my $self = shift;
  my %p = @_;
  exists $p{type} or $self->argh("requires 'type' argument");
  $self->info("Adding action type: ", $p{type}, "\n");
  return $self->add_callback_item('action', $p{type}, \%p);
}

=head2 C<add_stash($name, $value)>

This method is used by plugins to register a new type of stash to be
added to the template processing.  The value is typically a code
reference that is called lazily when the stash element is accessed.

=cut

sub add_stash {
  my ($self, $name, $value) = @_;
  exists $self->{_stash_zenah}->{$name} and
    $self->argh("plugin bug: stash element '$name' already exists");
  $self->info("Adding stash variable: ", $name, "\n");
  $self->{_stash_zenah}->{$name} = $value;
  return 1;
}

sub zenah_stash {
  return $_[0]->{_stash_zenah};
}

=head2 C<evaluate_action($template_string, $template_stash)>

This method is used to process a template (with the given stash)
and run the resulting actions.

=cut

sub evaluate_action {
  my $self = shift;
  my $action_document = shift;
  my $stash = shift || {};
  my $processed = $self->process_template($action_document, $stash);
  $processed =~ s/^\s*$//mg;
  return $self->run_action($processed, $stash);
}

=head2 C<run_action($action_string, $template_stash)>

This method executes a list of actions after it has been processed as
a template.

=cut

sub run_action {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $remaining = $action;
  while ($remaining) {
    my $command;
    ($command, $remaining) = split(/\r?\n+/, $remaining, 2);
    next if ($command =~ /^\s*$/ or $command =~ /^\s*#/);
    $command =~ s/^\s+//;
    my ($type, $spec) = split(/\s+/, $command, 2);
    unless ($self->exists_action($type)) {
      warn "no action defined for '$type'";
      next;
    }
    #$self->info('Action: ', $type, ' ', (defined $spec ? $spec : 'undef'),"\n");
    my $res = $self->action_callback($type)->(spec => $spec,
                                              remaining => $remaining,
                                              stash => $stash);
    if (defined $res && $res == -1) {
      # skip remaining actions
      last;
    }
  }
  return 1;
}

=head2 C<trigger_rule($rule)>

This method is executes the actions of a given rule.  It also updates
the "last fired" time, C<ftime>, field in the database.

=cut

sub trigger_rule {
  my $self = shift;
  my $rule = shift;
  #print "Triggered rule: ", $rule->name, "\n";
  my $action = $self->rule_template_document($rule);
  $rule->ftime(time);
  $rule->update();
  return $self->evaluate_action($action, @_);
}

=head2 C<trigger_rule_by_name($rule)>

This method is executes the actions of a named rule.  It also updates
the "last fired" time, C<ftime>, field in the database.

=cut

sub trigger_rule_by_name {
  my $self = shift;
  my $name = shift;
  my $rule = $self->{_db}->resultset('Rule')->single({ name => $name });
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->trigger_rule($rule, @_);
}

=head2 C<process_template($template_document, $template_stash)>

This method is applies the L<Template::Toolkit> to the given string
with the combination of the supplied stash and the "system" stash
that is polulated by the callbacks registered by the plugins.

=cut

sub process_template {
  my $self = shift;
  my $template_document = shift;
  my $stash = shift || {};
  my $output = '';
  eval {
    $output = $self->{_template}->{context}->process($template_document,
                                                     $stash);
  };
  if ($@) {
    warn 'Template error: '.$@;
  }
  return $output;
}

=head2 C<action_enable_rule(%params)>

This method is registered as a callback for the 'enable' action.  It
takes the name of a rule as the argument to the action and marks this
rule as enabled in the database.

=cut

sub action_enable_rule {
  my $self = shift;
  my %p = @_;
  $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $name = $p{spec};
  my $rule = $self->{_db}->resultset('Rule')->single({ name => $name });
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->enable_rule($rule);
}

=head2 C<enable_rule($rule)>

This method marks the given rule as enabled in the database.

=cut

sub enable_rule {
  my $self = shift;
  my $rule = shift;
  $rule->update({ active => 1 });
  return $self->read_rule($rule);
}

=head2 C<action_disable_rule(%params)>

This method is registered as a callback for the 'disable' action.  It
takes the name of a rule as the argument to the action and marks this
rule as disabled in the database.

=cut

sub action_disable_rule {
  my $self = shift;
  my %p = @_;
  $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $name = $p{spec};
  my $rule = $self->{_db}->resultset('Rule')->single({ name => $name });
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->disable_rule($rule);
}

=head2 C<disable_rule($rule)>

This method marks the given rule as disabled in the database.

=cut

sub disable_rule {
  my $self = shift;
  my $rule = shift;
  $rule->update({ active => 0 });
  return $self->read_rule($rule);
}

=head2 C<action_error(%params)>

This method is registered as a callback for the 'error' action.  It
takes an error string as arguments.

=cut

sub action_error {
  my $self = shift;
  my %p = @_;
  $p{spec} or return $self->ouch("requires 'spec' parameter");
  warn 'Error: ',$p{spec}, "\n";
  return 1;
}

=head2 C<action_debug(%params)>

This method is registered as a callback for the 'debug' action.  It
takes either:

=over

=item the word 'stash'

In which case the contents of the stash (excluding 'zenah' items) is
dumped to C<STDERR>.

=item the string '...'

In which case the remaining unprocessed rules are printed to C<STDERR>
and B<not> executed.

=item any string

In which case the string is printed on C<STDERR>.

=back

=cut

sub action_debug {
  my $self = shift;
  my %p = @_;
  defined $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $line = ('-'x78)."\n";
  if ($p{spec} eq '...') {
    warn $line, $p{remaining},"\n", $line;
    return -1; # skip remaining actions
  } elsif ($p{spec} eq "stash") {
    local $Data::Dumper::Sortkeys = 1;
    warn $line, Data::Dumper->Dump([$p{stash}],[qw/stash/]),"\n", $line;
  } else {
    warn $p{spec}, "\n";
  }
  return 1;
}

=head2 C<zenah_config($key)>

This method is used to lookup configuration items for the
L<ZenAH::Engine> from the database.  These configuration items are
stored in the C<map> table with a 'type' value of
'engine_config'.

=cut

sub zenah_config {
  my $self = shift;
  my $key = shift;
  my $conf =
    $self->{_db}->resultset('Map')->single({ type => 'engine_config',
                                             name => $key }) or return;
  return $conf->value;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

Project website: http://www.zenah.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>zenah@beanz.uklinux.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
