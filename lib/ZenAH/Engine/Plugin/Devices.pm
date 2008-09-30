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
    );

  $engine->add_stash(variable => "device",
                     callback => sub { return \%d });
  $engine->add_action(type => "device",
                      callback => sub { $self->action_device(@_); });
  return $self;
}

sub action_device {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->{_engine}->ouch("requires 'spec' parameter");
  my ($device_name, @args) = split /\s+/, $p{spec};
  my $device = ZenAH::CDBI::Device->search(name => $device_name)->first or
    return $self->{_engine}->ouch("device, $device_name, not found");
  return $self->{_engine}->run_action($device->action(@args));
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
