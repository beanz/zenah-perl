package ZenAH::Engine::Plugin::RRDs;

# $Id: RRDs.pm 2 2007-08-05 19:04:44Z beanz $

=head1 NAME

ZenAH::Engine::Plugin::RRDs - Perl extension for an ZenAH RRDs Plugin

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
use RRDs;

require Exporter;
use AutoLoader qw(AUTOLOAD);

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

It also sets up a timer to update any defined RRD databases every two
minutes.  In order for RRD databases to be active a Map entry must
exist in the database with type 'engine_config' and name 'rrd_dir'
the value is used as the path for any created RRD databases.

RRD databases may be defined by creating entries in the Map table
with type 'rrd_def' with name matching the type of entries in
the state table.  The values are a comma separated list with:

=over

=item the Data Source name

See the L<rrdcreate(1)> man page.

=item a fill flag

0 or 1 value.  0 means that if a value hasn't been updated recently
then the value should be treated as undefined and 1 means that current
value will be used regardless when it was last updated.

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

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my %d =
    (
     get => sub { return "not implemented" },
     set => sub { $self->set(@_) },
    );

  $engine->add_stash(rrd => sub { return \%d });
  return $self;
}

=head2 C<make_rrd($rrd_file, $definition)>

This method creates a new RRD database.

=cut

sub make_rrd {
  my ($self, $rrd, $var, $dstype, $min, $max) = @_;
  $dstype = $1 if ($dstype =~ /^MAP:([^:]+):/);
  my $dir = $rrd;
  $dir =~ s![^/]+$!!;
  mkpath($dir, undef, 0755) unless (-d $dir);
  print STDERR "Creating $rrd\n";
  RRDs::create($rrd,
               "--step", 60,
               "DS:$var:$dstype:300:$min:$max",
               "RRA:AVERAGE:0.5:1:6000", # 100 hours
               "RRA:AVERAGE:0.5:60:2400", # every hour for 100 days
               "RRA:AVERAGE:0.5:1440:400", # every day for 400 days
               "RRA:AVERAGE:0.5:10080:2080", # every week for 40 years
               "RRA:MIN:0.5:1:6000",
               "RRA:MIN:0.5:60:2400",
               "RRA:MIN:0.5:1440:400",
               "RRA:MIN:0.5:10080:2080",
               "RRA:MAX:0.5:1:6000",
               "RRA:MAX:0.5:60:2400",
               "RRA:MAX:0.5:1440:400",
               "RRA:MAX:0.5:10080:2080",
              );
  my $err = RRDs::error;
  if ($err) {
    warn "ERROR creating $rrd($var): $err\n";
    return;
  }
  return 1;
}

sub set {
  my ($self, $device, $uid, $type, $value, $time) = @_;
  $time = 'N' unless (defined $time);
  print STDERR "rrd set: $device, $uid, $type, $value, $time\n";
  my $name;
  my $rrd_alias =
    ZenAH::CDBI::Map->search(type => 'rrd_type',
                             name => $uid.':'.$type)->first;
  if ($rrd_alias) {
    ($type, $name) = split /\s*[:,]\s*/, $rrd_alias->value, 2;
  }
  $name = $type unless (defined $name);
  my $rrd_def =
    ZenAH::CDBI::Map->search(type => 'rrd_def', name => $type)->first or do {
      warn "No 'rrd_def' map entry for $type\n";
      return;
    };
  my $definition = [split /\s*,\s*/, $rrd_def->value];
  return $self->rrd_update($self->rrd_dir.'/'.$device.'/'.$name.'.rrd',
                           $value, $time, $definition);
}

=head2 C<rrd_update($rrd_dir, $dev, $val, $time, $definition)>

This method updates a single RRD database.

=cut

sub rrd_update {
  my ($self, $rrd, $value, $time, $definition) = @_;
  my ($var, $dstype, $min, $max) = @$definition;
  unless (-f $rrd) {
    print "Creating $rrd\n";
    $self->make_rrd($rrd, $var, $dstype, $min, $max) or return;
  }
  if ($dstype =~ /^MAP:(?:[^:]+):(.*)$/) {
    my %map = split /\s*[:=]\s*/, $1;
    $value = exists $map{$value} ? $map{$value} : 0;
  }
  RRDs::update($rrd, '-t', $var, $time.':'.$value);
  my $err = RRDs::error;
  if ($err) {
    warn "ERROR updating $rrd: $err\n";
    return;
  }
  return 1;
}

sub rrd_dir {
  my ($self) = @_;
  return $self->{_engine}->zenah_config('rrd_dir');
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
