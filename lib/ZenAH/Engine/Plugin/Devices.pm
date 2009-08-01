package ZenAH::Engine::Plugin::Devices;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::Devices - Perl extension for an ZenAH Devices Plugin

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
use ZenAH::CDBI;

require Exporter;
use AutoLoader qw(AUTOLOAD);

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

This plugin registers a 'device' action, see L<action_device()> below,
and a 'device' stash with the following operations:

=over

=item C<all>

Returns a list of all device objects.

=item C<by_name(device_name)>

Returns the device object for the named device.

=item C<by_type_list(type)>

Returns a list of device objects of the given type.

=item C<by_attr(attribute_name, attribute_value)>

Returns the device object (first if there are more than one) which
has the given attribute name and value.

=item C<by_type_and_attr(type, attribute_name, attribute_value)>

Returns the device object (first if there are more than one) of the
given type which has the given attribute name and value.

=item C<by_attr_list(attribute_name, attribute_value)>

Returns a list of device objects which have the given attribute name
and value.

=item C<by_attr_name_list(attribute_name)>

Returns a list of device objects which have an atrribute of the
specified name.

=back

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my %d =
    (
     all => sub {
       my @rooms =
         ZenAH::CDBI::Device->retrieve_all({ order_by => 'name'});
       return @rooms;
     },
     by_name => sub {
       return ZenAH::CDBI::Device->search(name => $_[0])->first;
     },
     by_type_list => sub {
       return map { $_ } ZenAH::CDBI::Device->search(type => $_[0]);
     },
     by_attr => sub {
       my $attr =
         ZenAH::CDBI::DeviceAttribute->search(name => $_[0],
                                              value => $_[1])->first or
                                                return;
       return $attr->devices->first;
     },
     by_type_and_attr => sub {
       return ZenAH::CDBI::Device->search_type_and_attr(@_)->first;
     },
     by_attr_list => sub {
       my $attr =
         ZenAH::CDBI::DeviceAttribute->search(name => $_[0],
                                              value => $_[1])->first or
                                                return;
       return map { $_ } $attr->devices;
     },
     by_attr_name_list => sub {
       my @res = ();
       foreach my $attr (ZenAH::CDBI::DeviceAttribute->search(name => $_[0])) {
         push @res, map { $_ } $attr->devices;
       }
       return @res;
     },
     guess => sub { return $self->guess(@_) },
    );

  $engine->add_stash(device => sub { return \%d });
  $engine->add_action(type => "device",
                      callback => sub { $self->action_device(@_); });
  $engine->add_action(type => "guess",
                      callback => sub { $self->action_guess(@_); });
  return $self;
}

=head2 C<action_device(%params)>

This method is registered as a callback for the 'device' action.  It
takes the name of a device and the name of a control to apply to the
device as arguments.

=cut

sub action_device {
  my $self = shift;
  my %p = @_;
  $p{spec} or return $self->{_engine}->ouch("requires 'spec' parameter");
  my ($device_name, @args) = split /\s+/, $p{spec};
  my $device = ZenAH::CDBI::Device->search(name => $device_name)->first or
    return $self->{_engine}->ouch("device, $device_name, not found");
  return $self->{_engine}->run_action($device->action(@args));
}

=head2 C<action_guess(%params)>

This method is registered as a callback for the 'guess' action.  It
takes a string and tries to determine a unique device/control pair
to apply.

=cut

sub action_guess {
  my $self = shift;
  my %p = @_;
  $p{spec} or return $self->{_engine}->ouch("requires 'spec' parameter");
  my $options = $self->guess($p{spec}) or return;
  return unless (scalar @{$options} == 1);
  my ($device, $control) = ($options->[0]->{device}, $options->[0]->{control});
  return $self->{_engine}->run_action($device->action($control->name));
}

sub guess {
  my ($self, $line) = @_;
  $line =~ s/\b(the|please|of|turn|set)\b//g;
  $line =~ s/\s+/ /g;
  my @words = split /\s+/, $line;
  my @rooms = ();
  foreach my $room (ZenAH::CDBI::Room->retrieve_all()) {
    next unless (match($line, $room));
    push @rooms, $room;
  }
  my @devices;
  foreach my $device (@rooms ? map { $_->devices } @rooms :
                      ZenAH::CDBI::Device->retrieve_all) {
    next unless (match($line, $device));
    push @devices, $device;
  }
  my @options;
  return unless (@devices);
  my %controls = ();
  foreach my $device (@devices) {
    foreach my $control ($device->controls) {
      next unless (match($line, $control));
      push @{$controls{$device}}, $control;
      push @options, { device => $device, control => $control };
    }
  }
  return \@options;
}

sub match {
  my ($line, $item) = @_;
  my $match = quotemeta lc $item->name;
  $match =~ s/[-_]/ /g;
  $match .= '|' . quotemeta lc $item->name;
  $match .= '|' . quotemeta lc $item->string;
  return $line =~ /\b$match\b/;
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
