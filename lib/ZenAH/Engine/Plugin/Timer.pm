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
use Time::HiRes;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

# Preloaded methods go here.

sub new {
  my $pkg = shift;
  $pkg = ref($pkg) if (ref($pkg));
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  exists $p{tz} or $p{tz} = 'Europe/London';
  my $tz = $self->{_tz} = $p{tz};

  $engine->add_action(type => 'sleep',
                      callback => sub { $self->action_sleep(@_); });

  $engine->add_trigger(type => "at",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) },
                      );

  $engine->add_stash(variable => "datetime",
                     callback => sub {
                       return sub {
                         my $dt = DateTime->now;
                         $dt->set_time_zone($tz);
                         return $dt;
                       };
                     });
  return $self;
}

sub add {
  my $self = shift;
  my %p = @_;
  exists $p{rule} or $self->argh("requires 'rule' parameter");
  exists $p{trigger} or $self->argh("requires 'trigger' parameter");
  my $rule = $p{rule}->id;
  my $trigger = $p{trigger};

  $self->{_engine}->add_timer(id => 'trigger-for-rule-'.$rule,
                              timeout => $trigger,
                              callback => sub { return $self->fire($rule, @_) },
                              );
  return 1;
}

sub remove {
  my $self = shift;
  my %p = @_;
  exists $p{rule} or $self->argh("requires 'rule' parameter");
  $self->{_engine}->remove_timer('trigger-for-rule-'.$p{rule});
  return 1;
}

sub fire {
  my $self = shift;
  my $rule = shift;
  $self->{_engine}->trigger_rule_by_id($rule);
  return 1;
}

sub action_sleep {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $timeout = $p{spec};
  my $remaining = $p{remaining};
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
