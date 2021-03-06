package ZenAH::Engine::Plugin::MQTT;

=head1 NAME

ZenAH::Engine::Plugin::MQTT - Perl extension for an ZenAH MQTT Plugin

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
use AnyEvent::MQTT;
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

This plugin registers an 'mqtt' action, see L<action_mqtt()> below,
and an 'mqtt' trigger for rules that are triggered based on incoming
MQTT messages, see L<add()> below.

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my $json = $self->{_json} = JSON->new;

  my $mqtt = $self->{_mqtt} =
    AnyEvent::MQTT->new(keep_alive_timer => 30,
                        on_error => sub {
                          my ($fatal, $message) = @_;
                          if ($fatal) {
                            die $message, "\n";
                          } else {
                            warn $message, "\n";
                          }
                        });

  $engine->add_trigger(type => "mqtt",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) });

  $engine->add_action(type => "mqtt",
                      callback => sub { $self->action_mqtt(@_) });

  $engine->add_timer(id => 'mqtt_timer',
                     timeout => -300,
                     callback => sub { $self->read(); 1; });

  return $self;
}

=head2 C<add($rule)>

This method is the callback that sets up the listeners for rules which
have the type 'mqtt'.  The trigger value, C<trig>, is simply used as
an MQTT topic.

=cut

sub add {
  my ($self, $rule) = @_;
  my $topic = $rule->trig;

  $self->{_mqtt_sub}->{$rule} =
    $self->{_mqtt}->subscribe(topic => $rule->trig,
                              callback => sub {
                                return $self->fire($rule, @_)
                              });
  return 1;
}

=head2 C<remove($rule)>

This method is the callback that removes the MQTT callbacks for rules
which have the type 'mqtt'.

=cut

sub remove {
  my ($self, $rule) = @_;
  $self->{_mqtt}->unsubscribe($rule->trig);
  delete $self->{_mqtt_sub}->{$rule};
  return 1;
}

=head2 C<fire($rule, %params)>

This method is the callback that triggers rules when an MQTT message is
matched.  It passes the mqtt message object to the action template as
the 'mqtt' entry in the stash.

=cut

sub fire {
  my ($self, $rule, $topic, $message, $obj) = @_;
  $self->{_engine}->trigger_rule($rule, { mqtt => $obj });
  return 1;
}

=head2 C<action_mqtt(%params)>

This method is registered as a callback for the 'mqtt' action.  It
takes an MQTT topic and message as arguments.

=cut

sub action_mqtt {
  my $self = shift;
  my %p = @_;
  my $spec = $p{spec}
    or return $self->{_engine}->ouch("requires 'spec' parameter");
  my %spec = simple_tokenizer($spec);
  $spec{message} = '' unless (defined $spec{message});
  $spec{topic} = '/zenah/missing-topic' unless (defined $spec{topic});
  $spec{qos} = 0 unless (defined $spec{qos});
  $self->{_mqtt}->publish(%spec);
  return 1;
}

=head2 C<read(%params)>

This timer callback reads the device/room details and publishes them
to MQTT.

=cut

sub read {
  my $self = shift;
  my $rs = $self->{_engine}->{_db}->resultset('Device')->search;

  while (my $device = $rs->next) {
    my %rec =
      (
       name => $device->name,
       string => $device->string,
       rooms => [ map { $_->name } $device->rooms ],
       controls => [ map { { name => $_->name, string => $_->string }
                         } $device->controls ],
      );
    $self->{_mqtt}->publish(topic => '/zenah/bnz/device/'.$device->name,
                            message => $self->{_json}->encode(\%rec),
                            retain => 1);
  }

  $rs = $self->{_engine}->{_db}->resultset('Room')->search;

  while (my $room = $rs->next) {
    my %rec =
      (
       name => $room->name,
       string => $room->string,
       devices => [ map { $_->name } $room->devices ],
      );
    $self->{_mqtt}->publish(topic => '/zenah/bnz/room/'.$room->name,
                            message => $self->{_json}->encode(\%rec),
                            retain => 1);
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

Mark Hindess, E<lt>zenah@beanz.uklinux.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
