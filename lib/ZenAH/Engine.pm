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
use Template::Stash;
use List::Util;
use Time::HiRes;
use xPL::Client;
use Module::Pluggable instantiate => 'new';
use ZenAH::CDBI;

require Exporter;
use AutoLoader qw(AUTOLOAD);

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
                             stash => [qw/callback callback_count/],
                             rule => [qw/mtime type/],
                            );

# VMethods
$Template::Stash::LIST_OPS->{largest} = sub { List::Util::max(@{$_[0]}) };
$Template::Stash::LIST_OPS->{smallest} = sub { List::Util::min(@{$_[0]}) };
$Template::Stash::LIST_OPS->{sum} = sub { List::Util::sum(@{$_[0]}) };
$Template::Stash::LIST_OPS->{mean} = sub { List::Util::sum(@{$_[0]})/@{$_[0]} };
$Template::Stash::LIST_OPS->{mean} = sub { List::Util::sum(@{$_[0]})/@{$_[0]} };
$Template::Stash::SCALAR_OPS->{int} = sub { int $_[0] };

# Preloaded methods go here.

sub new {
  my $pkg = shift;
  $pkg = ref($pkg) if (ref($pkg));

  my $self = $pkg->SUPER::new(vendor_id => 'bnz', device_id => 'zenah', @_);
  $self->init_triggers();
  $self->init_actions();
  $self->init_stashs();
  $self->init_rules();
  foreach my $plugin ($self->plugins(engine => $self)) {
    push @{$self->{_plugins}}, $plugin;
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

  $self->{_template} = Template->new({});

  print STDERR "Done.\n\n";
  return $self;
}

sub read_rules {
  my $self = shift;

  ZenAH::CDBI::Rule->clear_object_index();

  my $iter = ZenAH::CDBI::Rule->retrieve_all();

  while (my $rule = $iter->next) {
    $self->read_rule($rule);
  }

  return 1;
}

sub read_rule {
  my $self = shift;
  my $rule = shift;

  unless ($rule->active) {
    if ($self->exists_rule($rule)) {
      my $old_type = $self->rule_type($rule);
      $self->trigger_remove_callback($old_type)->(rule => $rule);
      $self->remove_rule($rule);
      print STDERR 'Removed rule: ', $rule->name, "\n";
    }
    return;
  }

  my $mtime = $rule->mtime;
  if ($self->exists_rule($rule)) {
    my $old_mtime = $self->rule_mtime($rule);
    return unless (defined $mtime &&
                   (!defined $old_mtime || $mtime->epoch > $old_mtime->epoch));
    my $old_type = $self->rule_type($rule);
    $self->trigger_remove_callback($old_type)->(rule => $rule);
    $self->remove_rule($rule);
    print STDERR 'Removed rule: ', $rule->name, "\n";
  }

  my $type = $rule->trig_type;
  unless ($type) {
    warn "empty trigger type: ",$rule->name, "\n";
    return;
  }

  unless ($self->exists_trigger($type)) {
    warn "unknown trigger type: $type ",$rule->name, " ",$rule->trig,"\n";
    return;
  }
  my $trig = $rule->trig;

  print STDERR 'Adding rule: ', $rule->name, "\n";

  $self->add_rule($rule, { mtime => $rule->mtime(), type => $type });

  $self->trigger_add_callback($type)->(rule => $rule, trigger => $trig);

  return 1;
}

sub add_trigger {
  my $self = shift;
  my %p = @_;
  exists $p{type} or $self->argh("requires 'type' argument");
  exists $p{add_callback} or $p{add_callback} = sub { 1 };
  exists $p{remove_callback} or $p{remove_callback} = sub { 1 };
  $p{add_callback_count} = 0;
  $p{remove_callback_count} = 0;
  print STDERR "Adding trigger type: ", $p{type}, "\n";
  return $self->add_item('trigger', $p{type}, \%p);
}

sub add_action {
  my $self = shift;
  my %p = @_;
  exists $p{type} or $self->argh("requires 'type' argument");
  print STDERR "Adding action type: ", $p{type}, "\n";
  return $self->add_callback_item('action', $p{type}, \%p);
}

sub add_stash {
  my $self = shift;
  my %p = @_;
  exists $p{variable} or $self->argh("requires 'variable' argument");
  print STDERR "Adding stash variable: ", $p{variable}, "\n";
  return $self->add_callback_item('stash', $p{variable}, \%p);
}

sub evaluate_action {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $processed = $self->process_template($action, $stash);
  $processed =~ s/^\s*$//mg;
  return $self->run_action($processed, $stash);
}

sub run_action {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $command;
  my $remaining = $action;
  while ($remaining &&
         (($command, $remaining) = split(/\r?\n+/, $remaining, 2))) {
    next if ($command =~ /^\s*$/ or $command =~ /^\s*#/);
    $command =~ s/^\s+//;
    my ($type, $spec) = split(/\s+/, $command, 2);
    unless ($self->exists_action($type)) {
      warn "no action defined for '$type'";
      next;
    }
    print STDERR "Action: ", $type, " ", $spec, "\n";
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

sub trigger_rule {
  my $self = shift;
  my $rule = shift;
  my $action = $rule->action;
  $rule->ftime(time);
  $rule->update();
  print STDERR "Triggering ", $rule->name, "\n";
  return $self->evaluate_action($action, @_);
}

sub trigger_rule_by_id {
  my $self = shift;
  my $id = shift;
  my $rule = ZenAH::CDBI::Rule->retrieve($id);
  unless ($rule) {
    return $self->ouch('no rule with id: '.$id);
  }
  return $self->trigger_rule($rule, @_);
}

sub trigger_rule_by_name {
  my $self = shift;
  my $name = shift;
  my $rule = ZenAH::CDBI::Rule->search(name => $name)->first;
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->trigger_rule($rule, @_);
}

sub process_template {
  my $self = shift;
  my $input = shift or return $self->ouch("empty template");
  my $stash = shift || {};
  foreach my $var ($self->stashs) {
    $stash->{zenah}->{$var} = $self->stash_callback($var)->();
  }
  my $output = '';
  $self->{_template}->process(\$input, $stash, \$output) or
    warn 'Template error: '.$self->{_template}->error();
  return $output;
}

sub action_enable_rule {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $name = $p{spec};
  my $rule = ZenAH::CDBI::Rule->search(name => $name)->first;
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->enable_rule($rule);
}

sub enable_rule {
  my $self = shift;
  my $rule = shift;
  $rule->active(1);
  $rule->update();
  return $self->read_rule($rule);
}

sub action_disable_rule {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $name = $p{spec};
  my $rule = ZenAH::CDBI::Rule->search(name => $name)->first;
  unless ($rule) {
    return $self->ouch('no rule with name: '.$name);
  }
  return $self->disable_rule($rule);
}

sub disable_rule {
  my $self = shift;
  my $rule = shift;
  $rule->active(0);
  $rule->update();
  return $self->read_rule($rule);
}

sub action_error {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  print STDERR 'Error: ',$p{spec}, "\n";
  return 1;
}

sub action_debug {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $line = ('-'x78)."\n";
  if ($p{spec} eq '...') {
    print STDERR $line, $p{remaining},"\n", $line;
    return -1; # skip remaining actions
  } elsif ($p{spec} eq "stash") {
    print STDERR $line, Data::Dumper->Dump([$p{stash}],[qw/stash/]),"\n", $line;
  } else {
    print STDERR $p{spec}, "\n";
  }
  return 1;
}

sub zenah_config {
  my $self = shift;
  my $key = shift;
  my $conf = ZenAH::CDBI::Map->search(type => 'engine_config',
                                      name => $key)->first or return;
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
