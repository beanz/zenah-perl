package ZenAH::Google::Chart;
use strict;
use warnings;
use base qw(Class::Accessor);
use POSIX qw/log10 ceil floor strftime/;
__PACKAGE__->mk_accessors(qw(width height
                             title type colours
                             data min max legend
                             right_data right_min right_max right_legend
                             xfmt xskip xmod fill));

sub url {
  my $self = shift;
  my $base = 'http://chart.apis.google.com/chart?';
  my @args = ();
  my $has_right_data = defined $self->right_data;
  push @args, 'cht='.$self->type;
  push @args, 'chs='.$self->width.'x'.$self->height;
  my @simple_data = ();
  my $g =
    $self->data_simple($self->min, $self->max, $self->data, \@simple_data);
  my $right_g =
    $self->data_simple($self->right_min, $self->right_max, $self->right_data,
                       \@simple_data) if ($has_right_data);
  push @args, 'chd=s:'.(join ',', @simple_data);
  my $colours = $self->colours;
  push @args, 'chco='.(join ',',@{$colours}) if (ref $colours &&
                                                 scalar @{$colours});
  my $xt = 'x,y';
  $xt .= ',r' if ($has_right_data);
  push @args, 'chxt='.$xt;
  my $xl = '0:|'.(join '|', @{$self->x_labels}).'|'.
           '1:|'.(join '|', @{$self->y_labels($g)});
  $xl .= '|2:|'.(join '|', @{$self->y_labels($right_g)})if ($has_right_data);
  push @args, 'chxl='.$xl;
  push @args, $self->fill if ($self->fill);
  my @legend = ();
  push @legend, @{$self->legend};
  push @legend, @{$self->right_legend} if ($has_right_data);
  push @args, 'chdl='.(join '|', @legend) if (scalar @legend);
  return $base.(join '&', @args);
}

sub data_simple {
  my $self = shift;
  my $min = shift;
  my $max = shift;
  my $data = shift;
  my $results = shift || [];
  my @ds = ();
  foreach my $d (@{$data}) {
    my ($x, @v) = @$d;
    my $i = 0;
    foreach (@v) {
      push @{$ds[$i]}, $_;
      $i++;
      next unless (defined $_);
      $max = $_ if (!defined $max || $max < $_);
      $min = $_ if (!defined $min || $min > $_);
    }
  }
  my $g = loose_label($min, $max);
  _simple_encode($g->{gmin}, $g->{gmax}, \@ds, $results);
  return $g;
}

sub _simple_encode {
  my ($min, $max, $data_sets, $results) = @_;
  my @enc = ('A'..'Z', 'a' .. 'z', '0'..'9');
  my $scale = ($max-$min)/61;
  $results = [] unless ($results);
  foreach my $values (@$data_sets) {
    push @$results, join '', map {
      defined $_ ? $enc[int(($_-$min)/$scale)] : '_'
    } @$values;
  }
  return $results;
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
  my $g = shift;
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
