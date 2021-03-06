package ZenAH::Engine::Plugin::Pachube;

# $Id: Pachube.pm 2 2007-08-05 19:04:44Z beanz $

=head1 NAME

ZenAH::Engine::Plugin::Pachube - Perl extension for an ZenAH Pachube Plugin

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
use File::Path;
use ZenAH::CDBI;
use HTTP::Request;
use LWP::UserAgent;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision: 2 $/[1];

# Preloaded methods go here.

=head2 C<new(%params)>

The constructor creates a new plugin object.  The constructor takes a
parameter hash as arguments.  Valid parameters in the hash are:

=over

=item engine

This is a reference to the engine that is instantiating the plugin.

=back

It returns a blessed reference when successful or undef otherwise.

This plugin registers an 'rrd' stash with the following operations:

=over

=item C<get()>

Not implemented yet.

=back

In order for RRD databases to be active a Map entry must
exist in the database with type 'engine_config' and name 'rrd_dir'
the value is used as the path for any created RRD databases.

RRD databases may be defined by creating entries in the Map table
with type 'rrd_def' with name matching the type of entries in
the state table.  The values are a comma separated list with:

=over

=item the Data Source name

See the L<rrdcreate(1)> man page.

=item the Data Source Type (DST)

See the L<rrdcreate(1)> man page.  Additionally, the DST can also be
of the form 'MAP:DST:...' where MAP is just an identifier, DST is the
real RRD DST and ... is 1 or more key value pair used to map values in
the state table to values to enter in the RRD database.  If no
matching key is found the RRD value will be 0.  For example,
'MAP:GAUGE:on=1:off=0' could be used to Map on/off values in the state
table to 0 and 1 to record in an RRD database.

=item the min value

See the L<rrdcreate(1)> man page.

=item the max value

See the L<rrdcreate(1)> man page.

=back

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  eval { require Net::Pachube; };
  return $self if ($@);

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  $self->{_pachube} = Net::Pachube->new(key => $self->pachube_api_key);
  my %d =
    (
     get => sub { return "not implemented" },
     set => sub { $self->set(@_) },
    );

  $engine->add_stash(pachube => sub { return \%d });
  return $self;
}

sub set {
  my ($self, $device, $uid, $type, $value, $time) = @_;
  my $id = $device.'/'.$uid;
  my $def =
    ZenAH::CDBI::Map->search(type => 'pachube_def', name => $id)->first;
  unless ($def) {
    $id = $device.'/'.$type;
    $def =
      ZenAH::CDBI::Map->search(type => 'pachube_def', name => $id)->first;
    unless ($def) {
      warn "No 'pachube_def' map entry for $id\n";
      return;
    }
  }

  eval {
    my ($feed_id, $title) = split /\s*,\s*/, $def->value, 2;
    my $feed = $self->{_pachube}->feed($feed_id, 0);
    my $r = $feed->update(data => $value) or
      die "update failed: ", $self->{_pachube}->http_response->status_line,"\n";
  };
  warn "Pachube: $@\n" if ($@);
  return 1;
}

sub pachube_api_key {
  my ($self) = @_;
  return $self->{_engine}->zenah_config('pachube_api_key');
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

Copyright (C) 2008 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
