package ZenAH::Engine::Plugin::Redis;

=head1 NAME

ZenAH::Engine::Plugin::Redis - Perl extension for an ZenAH Redis Plugin

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
use AnyEvent::Redis;
use xPL::Base qw/simple_tokenizer/;
use JSON;

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

This plugin registers a 'redis_publish' action, see L<action_pub()>
below, and a 'redis_sub' trigger for rules that are triggered based on
incoming Redis messages, see L<add()> below.

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my $json = $self->{_json} = JSON->new;

  my $redis = $self->{_redis} =
    AnyEvent::Redis->new(host => '127.0.0.1',
                         on_error => sub {
                           die "redis: @_";
                         });

  my $redis_sub = $self->{_redis_sub} =
    AnyEvent::Redis->new(host => '127.0.0.1',
                         on_error => sub {
                           die "redis subscription: @_";
                         });

  $engine->add_trigger(type => 'redis',
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) });

  $engine->add_action(type => 'redis',
                      callback => sub { $self->action_redis(@_) });

  $engine->add_timer(id => 'redis_timer',
                     timeout => -300,
                     callback => sub { $self->read(); 1; });

  return $self;
}

=head2 C<add($rule)>

This method is the callback that sets up the listeners for rules which
have the type 'redis'.  The trigger value, C<trig>, is simply used as
an Redis topic.

=cut

sub add {
  my ($self, $rule) = @_;
  my $topic = $rule->trig;

  $self->{_subs}->{$rule} =
    $self->{_redis_sub}->psubscribe($rule->trig,
                                    callback => sub {
                                      return $self->fire($rule, @_)
                                    });
  return 1;
}

=head2 C<remove($rule)>

This method is the callback that removes the Redis callbacks for rules
which have the type 'redis'.

=cut

sub remove {
  my ($self, $rule) = @_;
  $self->{_redis_sub}->punsubscribe($rule->trig);
  delete $self->{_subs}->{$rule};
  return 1;
}

=head2 C<fire($rule, %params)>

This method is the callback that triggers rules when an Redis message is
matched.  It passes the redis message object to the action template as
the 'redis' entry in the stash.

=cut

sub fire {
  my ($self, $rule, $message, $topic, $pattern) = @_;
  $self->{_engine}->trigger_rule($rule,
                                 { message => $message, topic => $topic });
  return 1;
}

=head2 C<action_redis(%params)>

This method is registered as a callback for the 'redis' action.  It
takes Redis command and arguments as arguments.

=cut

sub action_redis {
  my $self = shift;
  my %p = @_;
  my $spec = $p{spec}
    or return $self->{_engine}->ouch("requires 'spec' parameter");
  my ($command, @args) = simple_tokenizer($spec);
  my $cv = $self->{_redis}->$command(@args);
  $self->{_cv}->{$cv} = $cv;
  $cv->cb(sub {
            my $cv = shift;
            my ($res, $err) = $cv->recv;
            warn "redis $command: $err\n" if (defined $err);
            delete $self->{_cv}->{$cv};
          });
  return 1;
}

=head2 C<read(%params)>

This timer callback reads the device/room details and sets them in Redis.

=cut

sub read {
  my $self = shift;
  my $rs = $self->{_engine}->{_db}->resultset('Device')->search;

  while (my $device = $rs->next) {
    my %rec =
      (
       name => $device->name,
       string => $device->string,
       rooms => $self->{_json}->encode([ map { $_->name } $device->rooms ]),
       controls =>
         $self->{_json}->encode([ map {
           { name => $_->name, string => $_->string }
         } $device->controls ]),
      );
    my $cv = $self->{_redis}->hmset('device.'.$device->name, %rec);
    $self->{_cv}->{$cv} = $cv;
    $cv->cb(sub {
              my $cv = shift;
              my ($res, $err) = $cv->recv;
              warn "redis hmset: $err\n" if (defined $err);
              delete $self->{_cv}->{$cv};
            });
  }

  $rs = $self->{_engine}->{_db}->resultset('Room')->search;

  while (my $room = $rs->next) {
    my %rec =
      (
       name => $room->name,
       string => $room->string,
       #devices => $self->{_json}->encode([ map { $_->name } $room->devices ]),
      );
    my $cv = $self->{_redis}->hmset('room.'.$room->name, %rec);
    $self->{_cv}->{$cv} = $cv;
    $cv->cb(sub {
              my $cv = shift;
              my ($res, $err) = $cv->recv;
              warn "redis hmset: $err\n" if (defined $err);
              delete $self->{_cv}->{$cv};
            });
  }
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

Project website: http://www.zenah.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>soft-github@temporalanomaly.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
