package ZenAH::Google::Chart;
use strict;
use warnings;
use base qw(Class::Accessor);
use POSIX qw/log10 ceil floor strftime/;
__PACKAGE__->mk_accessors(qw(width height
                             title data type colours legend
                             data_labels min max xfmt xskip xmod fill));

sub url {
  my $self = shift;
  my $base = 'http://chart.apis.google.com/chart?';
  my @args = ();
  push @args, 'cht='.$self->type;
  push @args, 'chs='.$self->width.'x'.$self->height;
  push @args, 'chd='.$self->data_simple;
  my $colours = $self->colours;
  push @args, 'chco='.(join ',',@{$colours}) if (ref $colours &&
                                                 scalar @{$colours});
  push @args, 'chxt=x,y';
  push @args, 'chxl=0:|'.(join '|', @{$self->x_labels}).'|'.
                   '1:|'.(join '|', @{$self->y_labels});
  push @args, $self->fill if ($self->fill);
  my $legend = $self->legend;
  push @args, 'chdl='.(join '|', @$legend) if ($legend);
  return $base.(join '&', @args);
}

sub data_simple {
  my $self = shift;
  my $min = $self->min;
  my $max = $self->max;
  my %ds = ();
  foreach my $d (@{$self->data}) {
    my ($x, @v) = @$d;
    my $i = 0;
    foreach (@v) {
      push @{$ds{$i}}, $_;
      $i++;
      next unless (defined $_);
      $max = $_ if (!defined $max || $max < $_);
      $min = $_ if (!defined $min || $min > $_);
    }
  }
  my $g = $self->{_g} = loose_label($min, $max);
  my @enc = ('A'..'Z', 'a' .. 'z', '0'..'9');
  my $scale = ($g->{gmax}-$g->{gmin})/61;
  my @s = ();
  my $gmin = $g->{gmin};
  foreach my $i (sort { $a <=> $b } keys %ds) {
    my $values = $ds{$i};
    push @s, join '', map {
      defined $_ ? $enc[int(($_-$gmin)/$scale)] : '_'
    } @$values;
  }
  return 's:'.(join ',', @s);
}

sub x_labels {
  my $self = shift;
  my @l = ();
  my $p = '';
  my $skip = $self->xskip || 1;
  my $mod = $self->xmod || 1;
  my $fmt = $self->xfmt;

  my $bands = scalar @{$self->data} - 1;
  my $bwidth = 1/$bands;
  my @bc = ('ffffff', 'cccccc');

  my $fn = ($fmt =~ s/^!// ?
            sub { strftime $_[0], localtime $_[1] } :
            sub { sprintf $_[0], $_[1] });

  my $c = 0;
  my $cb = 0;
  my @fill = ();
  foreach my $x (map { $_->[0] } @{$self->data}) {
    my $l = $fn->($fmt, $x);
    next if ($p eq $l);
    if (($c%$skip) == 0 && ($l%$mod) == 0) {
      push @l, $l;
      $cb++;
    } else {
      push @l, '';
    }
    push @fill, $bc[$cb % scalar @bc].','.(sprintf '%.4f',$bwidth);
    $c++;
    $p = $l;
  }
  $self->fill('chf=c,ls,0,'.(join ',', @fill)) if ($self->fill);
  return \@l;
}

sub y_labels {
  my $self = shift;
  my $g = $self->{_g};
  return [ map { sprintf $g->{stepfmt}, $_ } @{$g->{ticks}} ];
}

# Reference: Paul Heckbert, "Nice Numbers for Graph Labels",
#            Graphics Gems, pp 61-63.
#            http://tog.acm.org/GraphicsGems/gems/Label.c
#
# Finds a "nice" number approximately equal to x.
#
# Args:
#       x -- target number
#   round -- If non-zero, round. Otherwise take ceiling of value.

sub nice_number {
  my $x = shift;
  my $round = shift;

  my $e = floor(log10($x));
  my $f = $x / 10**$e;
  my $n = 10;
  if ($round) {
    $n = ($f < 1.5 ? 1.0 : ($f < 3 ? 2 : ($f < 7 ? 5 : 10)));
  } else {
    $n = ($f <= 1 ? 1.0 : ($f <= 2 ? 2 : ($f <= 5 ? 5 : 10)));
  }
  return $n * 10**$e;
}

sub loose_label {
  my ($min, $max, $steps) = @_;
  $steps = 8 if (!defined $steps);
  $steps = 2 if ($steps < 2);

  my $range = nice_number($max - $min);
  my $delta = nice_number($range/($steps - 1), 1);
  my $gmin = $delta * floor($min/$delta);
  my $gmax = $delta * ceil($max/$delta);
  my $nfx = -floor(log10($delta));
  my $nfrac = ($nfx > 0) ? $nfx : 0;
  my $fmt = sprintf("%%.%df", $nfrac);
  my @tick = ();
  for (my $x=$gmin; $x < $gmax + 0.5*$delta; $x+=$delta) {
    push @tick, $x;
  }
  return { gmin => $gmin, gmax => $gmax,
           delta => $delta, stepfmt => $fmt,
           ticks => \@tick };
}

1;
