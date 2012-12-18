package ZenAH::Engine::Plugin::Timer;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::Timer - Perl extension for an ZenAH Timer Plugin

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
use DateTime;
use DateTime::TimeZone;
use Time::HiRes;

require Exporter;

our @ISA = qw(Exporter);
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

This plugin registers a 'sleep' action, which causes the remaining
actions to be delayed.  It registers an 'at' trigger for rules that
are triggered based on L<xPL::Timer> events.  It registers a
'datetime' stash which returns a L<DateTime> object of the current
time.

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  exists $p{tz} or $p{tz} = $ENV{TZ} || 'Europe/London';
  my $tz = $self->{_tz} = DateTime::TimeZone->new(name => $p{tz});

  $engine->add_action(type => 'sleep',
                      callback => sub { $self->action_sleep(@_); });

  $engine->add_trigger(type => "at",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) },
                      );

  $engine->add_stash(datetime => sub {
                       my $dt = DateTime->now;
                       $dt->set_time_zone($tz);
                       return $dt;
                     });
  $engine->add_stash(time => sub { time });
  return $self;
}

=head2 C<add($rule)>

This method is the callback that sets up the timers for rules which
have the type 'at'.  The trigger, C<trig>, value is passed directly
to the L<xPL::Listener::add_timer()> method.  Supported values for the
trigger are describe in the documentation for that method.

=cut

sub add {
  my ($self, $rule) = @_;
  return $self->{_engine}->add_timer(id => 'trigger-for-rule-'.$rule,
                                     timeout => $rule->trig,
                                     callback => sub {
                                       return
                                         $self->{_engine}->trigger_rule($rule);
                                     },
                              );
}

=head2 C<remove($rule)>

This method is the callback that removes the timers for rules which
have the type 'at'.

=cut

sub remove {
  my ($self, $rule) = @_;
  return $self->{_engine}->remove_timer('trigger-for-rule-'.$rule);
}

=head2 C<action_sleep(%params)>

This method is registered as a callback for the 'sleep' action.  It
takes a timeout as arguments.  The timeout value is passed directly to
the L<xPL::Listener::add_timer()> method.  Supported values for the
timeout are describe in the documentation for that method.

=cut

sub action_sleep {
  my $self = shift;
  my %p = @_;
  my $timeout =
    $p{spec} or return $self->{_engine}->ouch("requires 'spec' parameter");
  my $remaining =
    $p{remaining} or return $self->{_engine}->ouch("sleep for nothing?");
  $self->{_engine}->add_timer(id => '~tmp~sleep~'.Time::HiRes::time.'~'.rand,
                              timeout => $timeout,
                              callback => sub {
                                $self->{_engine}->run_action($remaining);
                                return;
                              });
  return -1; # skip remaining actions
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

Copyright (C) 2006, 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
