package ZenAH::Engine::Plugin::xPL;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::xPL - Perl extension for an ZenAH xPL Plugin

=head1 SYNOPSIS

  # Loaded by ZenAH::Engine

=head1 DESCRIPTION

This is a module for the Zen Automated Home Engine.  It provides a
main loop and allows callbacks to be registered for events that
occur.  It also configures the L<ZenAH::Engine::Plugin>.

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
use xPL::Message;
use xPL::Base qw/simple_tokenizer/;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(xPL::Base);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

# Preloaded methods go here.

=head2 C<new(%params)>

The constructor creates a new plugin object.  The constructor takes a
parameter hash as arguments.  Valid parameters in the hash are:

=over

=item engine

This is a reference to the engine that is instantiating the plugin.

=back

It returns a blessed reference when successful or undef otherwise.

This plugin registers an 'xpl' action, see L<action_xpl()> below,
and an 'xpl' trigger for rules that are triggered based on incoming
xPL messages, see L<add()> below.

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};

  $engine->add_trigger(class => "xpl",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) });

  $engine->add_action(class => "xpl",
                      callback => sub { $self->action_xpl(@_) });
  return $self;
}

=head2 C<add($rule)>

This method is the callback that sets up the listeners for rules which
have the class 'xpl'.  The trigger, C<trig>, value is passed directly
to the L<xPL::Listener::add_xpl_callback()> method.  Supported values
for the trigger are describe in the documentation for that method.
Additionally, for filtering on 'device' fields only, as fast lookup
is supported with the following syntax:

=over

=item C<lookup_map(class)>

Filters xPL messages depending on whether the value of the device field
appears as a 'name' in the Map table with the given class.  This is used
to avoid firing rules that will do lookups using the 'map' stash in the
template but fail becuase no entry is found.

=item C<lookup_blah(arg1,arg2,...)>

Filters xPL messages depending on whether the
L<ZenAH::CDBI::Device::search_blah(arg1, arg2, ..., device)> returns
true for the given device.

=back

=cut

sub add {
  my ($self, $rule) = @_;
  my %filter = simple_tokenizer($rule->trig);
# TOFIX: shouldn't need this here?
  if (exists $filter{class} && $filter{class} =~ /^(\w+)\.(\w+)$/) {
    $filter{class} = $1;
    $filter{class_type} = $2;
  }
  if ($filter{'device'} && $filter{'device'} =~ /^lookup_(\w+)\[([^]]+)\]$/) {
    if ($1 eq 'map') {
      my $arg = $2;
      $filter{'device'} =
        sub { ZenAH::CDBI::Map->search(class => $arg, name => $_[0])->first };
    } else {
      my $lookup = 'search_'.$1;
      my @arg = split /,/, $2;
      $filter{'device'} =
        sub {
          my $res;
          eval { $res = ZenAH::CDBI::Device->$lookup(@arg, $_[0]) };
          warn $rule->name." lookup error: $@\n" if ($@);
          return $res;
        };
    }
  }

  $self->{_engine}->add_xpl_callback(id => 'trigger-for-rule-'.$rule,
                                     targetted => 0,
                                     self_skip => 0,
                                     filter => \%filter,
                                     callback => sub {
                                       return $self->fire($rule, @_)
                                     });
  return 1;
}

=head2 C<remove($rule)>

This method is the callback that removes the xPL callbacks for rules
which have the class 'xpl'.

=cut

sub remove {
  my ($self, $rule) = @_;
  $self->{_engine}->remove_xpl_callback('trigger-for-rule-'.$rule);
  return 1;
}

=head2 C<fire($rule, %params)>

This method is the callback that triggers rules when an xPL message is
matched.  It passes the xpl message object to the action template as
the 'xpl' entry in the stash.

=cut

sub fire {
  my $self = shift;
  my $rule = shift;
  my %p = @_;
  $self->{_engine}->trigger_rule($rule, { xpl => $p{message} });
  return 1;
}

=head2 C<action_xpl(%params)>

This method is registered as a callback for the 'xpl' action.  It
takes an xPL message string as arguments.  The message string value is
passed directly to the L<xPL::Listener::send_from_string()> method.
Supported values for the message string are describe in the
documentation for that method.

=cut

sub action_xpl {
  my $self = shift;
  my %p = @_;
  my $spec = $p{spec}
    or return $self->{_engine}->ouch("requires 'spec' parameter");
  eval {
    $self->{_engine}->send_from_string($spec);
  };
  $self->{_engine}->ouch($@) if ($@);
  return 1;
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
