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

sub new {
  my $pkg = shift;
  $pkg = ref($pkg) if (ref($pkg));
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my %d =
    (
     get => sub { return "not implemented" },
    );

  $engine->add_stash(variable => "rrd",
                     callback => sub { return \%d });

  $engine->add_timer(id => 'update_rrd_files',
                     timeout => -120,
                     callback => sub { $self->update_rrd_files(@_); 1 });

  return $self;
}

sub update_rrd_files {
  my $self = shift;
  my $time = time;
  my $rrd_dir = $self->{_engine}->zenah_config('rrd_dir') or do {
    print STDERR "zenah_config[rrd_dir] is not defined\n";
    return;
  };
  my %types = map { $_->name => [split /\s*,\s*/, $_->value]
                  } ZenAH::CDBI::Map->search(type => 'rrd_type');
  foreach my $state (ZenAH::CDBI::State->retrieve_all()) {
    my $definition = $types{$state->type};
    next unless (defined $definition);
    $self->update_rrd($rrd_dir,
               $time, $state->name, $state->mtime->epoch, $state->value,
               $definition);
  }
  return 1;
}

sub update_rrd {
  my ($self, $rrd_dir, $time, $dev, $last, $val, $definition) = @_;
  my ($var, $fill, $dstype, $min, $max) = @$definition;
  my $rrd = $rrd_dir.'/'.$dev.'/'.$var.'.rrd';
  unless (-f $rrd) {
    $self->make_rrd($rrd, $definition) or return;
  }
  my $t = $fill ? $time : $last;
  if ($self->{_last}->{$rrd} && $self->{_last}->{$rrd} >= $t) {
    return 1;
  }
  if ($dstype =~ /^MAP:(?:[^:]+):(.*)$/) {
    my %map = split /\s*[:=]\s*/, $1;
    $val = exists $map{$val} ? $map{$val} : 0;
  }
  RRDs::update($rrd, '-t', $var, $t.':'.$val);
  my $err = RRDs::error;
  if ($err) {
    warn "ERROR updating $rrd: $err\n";
    return;
  }
  return 1;
}

sub make_rrd {
  my ($self, $rrd, $definition) = @_;
  my ($var, $fill, $dstype, $min, $max) = @$definition;
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