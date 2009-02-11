package ZenAH::Google::Chart;
use strict;
use warnings;
use base qw(Class::Accessor);
use POSIX qw/log10 ceil floor strftime/;
use RRDs;

__PACKAGE__->mk_accessors(qw(preset
                             width height
                             title type colours
                             data min max legend
                             start end span resolution
                             right_data right_min right_max right_legend
                             xformat xskip xmodulo
                             xformat2 xskip2 xmodulo2
                             fill));

my %defaults =
  (
   width => 680,
   height => 300,
   xmodulo => 4,
   xmodulo2 => 1,
   fill => 1,
   colours => ['0000ff', 'ff0000', 'ffff00',
               '00ff00', '00ffff', 'ff00ff'],
   type => 'lc',
  );

my %presets =
  (
   one_hour => {
                span => 3600,
                resolution => 60,
                xformat => '!%M',
                xformat2 => '!%H',
               },
   one_day => {
               span => 86400,
               resolution => 1800,
               xformat => '!%H',
               xformat2 => '!%w~%a',
              },
   one_week => {
                span => 604800,
                resolution => 7200,
                xformat => '!%w~%a',
                xmodulo => 1,
                xformat2 => '!%U~%m-%d',
               },
   one_month => {
                 span => 2678400,
                 resolution => 43200,
                 xformat => '!%w~%a',
                 xformat2=>'!%U~%m-%d',
                },

   three_months => {
                    span => 8035200,
                    resolution => 86400,
                    xformat => '!%U~%m-%d',
                    xmodulo => 1,
                    xformat2 => '!%m~%b',
                   },
   six_months => {
                  span => 16070400,
                  esolution => 86400,
                  xformat => '!%U~%m-%d',
                  xmodulo => 1,
                  xformat2 => '!%m~%b',
                 },
   one_year => {
                span => 31622400,
                resolution => 172800,
                xformat => '!%m~%b',
                xmodulo => 1,
                xformat2 => '!%Y',
               },
   two_years => {
                 span => 63244800,
                 resolution => 604800,
                 xformat => '!%m~%b',
                 xmodulo => 2,
                 xformat2 => '!%Y',
                },
   four_years => {
                  span => 126489600,
                  resolution => 1209600,
                  xformat => '!%m~%b',
                  xmodulo => 3,
                  xformat2 => '!%Y',
                 }
  );

sub new {
  my ($pkg, $opt) = @_;
  if (ref $pkg) { $pkg = ref $pkg }
  $opt = {} unless (defined $opt);
  my %args = ();
  my $preset = $opt->{preset};
  if (defined $preset) {
    if (exists $presets{$preset}) {
      %args = %{$presets{$preset}};
    } else {
      die "Preset, $preset, is not defined\n";
    }
  }
  my $self = $pkg->SUPER::new({%defaults, %args, %{$opt}}) or return;
  my $start = $self->start;
  my $end = $self->end;
  my $span = $self->span;
  my $resolution = $self->resolution;
  if (defined $start) {
    $start = int($start/$resolution)*$resolution;
    $end = $start+$resolution*int(0.5+$span/$resolution);
  } else {
    $end = int((defined $end ? $end : time)/$resolution)*$resolution;
    $start = $end-$resolution*int(0.5+$span/$resolution);
  }
  $self->start($start);
  $self->end($end);
  print STDERR "Time: $start - $end\n";
  print STDERR "Samples: ", $self->span/$self->resolution, "\n";

  return $self;
}

sub add_from_source {
  my ($self, $source) = @_;
  $source = source_from_string($source) unless (ref $source);
  return $self->fetch_from_source($source);
}

sub source_from_string {
  my $string = shift;
  my ($file, @rest);
  ($file, @rest) = split /\|/, $string;
  my %source =
    (
     file => $file,
     side => 'l',
     cf => 'AVERAGE',
     offset_t => 0,
     map { split /=/, $_, 2 } @rest
    );
  $source{'side'} = lc substr $source{'side'}, 0, 1;
  unless (defined $source{'legend'}) {
    $source{'legend'} = $source{'file'};
    $source{'legend'} =~ s!/([^/]+)$! $1!;
    $source{'legend'} =~ s!^.*\/!!;
    $source{'legend'} =~ s!\.rrd$!!;
  }
  return \%source;
}

sub fetch_from_source {
  my ($self, $source) = @_;
  my ($start, $step, $names, $data) =
    $self->my_rrd_fetch($source->{'file'}, $source->{'cf'},
                        $self->resolution,
                        $self->start - $source->{'offset_t'},
                        $self->end - $source->{'offset_t'});

  my $resolution = $self->resolution;
  my $step_mod = $resolution/$step;
  print STDERR "Adding data from ",$source->{'file'},
    ' ', $source->{'offset_t'}, "\n";
  print STDERR
    "  resolution=$resolution, step=$step, step_mod=$step_mod, length=",
      (scalar @$data), "\n";
  my $side = $source->{'side'};
  my $self_data;
  my $self_legend;
  if ($side eq 'l') {
    $self_data = $self->data;
    unless ($self_data) {
      $self->data([]);
      $self_data = $self->data;
    }
    $self_legend = $self->legend;
    unless ($self_legend) {
      $self->legend([]);
      $self_legend = $self->legend;
    }
  } else {
    $self_data = $self->right_data;
    unless ($self_data) {
      $self->right_data([]);
      $self_data = $self->right_data;
    }
    $self_legend = $self->right_legend;
    unless ($self_legend) {
      $self->right_legend([]);
      $self_legend = $self->right_legend;
    }
  }

  my $legend = $source->{'legend'};
  my %ds_index;
  {
    my $count = 0;
    $ds_index{$_} = $count++ foreach (@$names);
  }
  my $ds = $source->{'ds'};
  die "Invalid DS, $ds, from ",$source->{'file'},"\n"
    if (defined $ds && !exists $ds_index{$ds});
  my @ds;
  if (defined $ds) {
    @ds = ($ds);
    print STDERR "  pushing '$legend' to legend\n";
    push @{$self_legend}, $legend;
  } else {
    @ds = @$names;
    foreach (@ds) {
      my $l = $_.($legend ? ' '.$legend : '');
      print STDERR "  pushing '$l' to legend\n";
      push @{$self_legend}, $l;
    }
  }
  my $index = 0;
  my $count = 0;
  my @sum = ();
  my @num = ();
  foreach my $line (@$data) {
    $count++;
    foreach my $i (map { $ds_index{$_} } @ds) {
      if (defined $line->[$i]) {
	$sum[$i] += $line->[$i];
	$num[$i]++;
      }
    }
    my $sample = (($count%$step_mod) == 0);
    if ($sample) {
      unless (defined $self_data->[$index]) {
#        print STDERR "Pushing start '$start' to data\n";
	push @{$self_data->[$index]}, $start;
      }
      foreach my $i (map { $ds_index{$_} } @ds) {
	my $val = $num[$i] ? $sum[$i]/$num[$i] : undef;
        print STDERR "Pushing val ",
          (defined $val ? "'$val'" : 'undef'), " to data\n";
	push @{$self_data->[$index]}, $val;
      }
      $start += $resolution;
      $index++;
      @sum = ();
      @num = ();
    } else {
    }
  }
  return 1;
}

sub my_rrd_fetch {
  my ($self, $file, $cf, $resolution, $start, $end) = @_;
  my $key = join '!', @_;
  unless (exists $self->{_cache_rrd}->{$key}) {
    print STDERR "rrdtool fetch $file $cf -r $resolution, -s $start -e $end\n";
    $self->{_cache_rrd}->{$key} =
      [ RRDs::fetch $file, $cf, '-r', $resolution, '-s', $start, '-e', $end ];
  }
  return
    wantarray ? @{$self->{_cache_rrd}->{$key}} : $self->{_cache_rrd}->{$key};
}

sub url {
  my $self = shift;
  my $base = 'http://chart.apis.google.com/chart?';
  my @args = ();
  my $has_right_data = defined $self->right_data;
  push @args, 'cht='.$self->type;
  push @args, 'chs='.$self->width.'x'.$self->height;
  my @simple_data = ();
  my $g =
    $self->data_extended($self->min, $self->max, $self->data, \@simple_data);
  my $right_g =
    $self->data_extended($self->right_min, $self->right_max, $self->right_data,
                       \@simple_data) if ($has_right_data);
  push @args, 'chd=e:'.(join ',', @simple_data);
  my $colours = $self->colours;
  push @args, 'chco='.(join ',',@{$colours}) if (ref $colours &&
                                                 scalar @{$colours});
  my $xt = 'x,y';
  $xt .= ',r' if ($has_right_data);
  $xt .= ',x' if ($self->xformat2);
  push @args, 'chxt='.$xt;
  my $index = 0;
  my $xl = $index++.':|'.(join '|', @{$self->x_labels($self->fill)}).'|'.
           $index++.':|'.(join '|', @{$self->y_labels($g)});
  $xl .= '|'.$index++.':|'.(join '|', @{$self->y_labels($right_g)})
    if ($has_right_data);
  $xl .= '|'.$index++.':|'.(join '|', @{$self->x_labels(0,
                                             $self->xformat2,
                                             $self->xmodulo2,
                                             $self->xskip2,
                                            )}) if ($self->xformat2);
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
  my ($g, $ds) = _min_max_data($min, $max, $data);
  _simple_encode($g->{gmin}, $g->{gmax}, $ds, $results);
  return $g;
}

sub data_extended {
  my $self = shift;
  my $min = shift;
  my $max = shift;
  my $data = shift;
  my $results = shift || [];
  my ($g, $ds) = _min_max_data($min, $max, $data);
  _extended_encode($g->{gmin}, $g->{gmax}, $ds, $results);
  return $g;
}

sub _min_max_data {
  my ($min, $max, $data) = @_;
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
  return ($g, \@ds);
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

sub _extended_encode {
  my ($min, $max, $data_sets, $results) = @_;
  my @enc = ('A'..'Z', 'a' .. 'z', '0'..'9', '-', '.');
  my $num_enc = scalar @enc;
  my $scale = ($max-$min)/4095;
  $results = [] unless ($results);
  foreach my $values (@$data_sets) {
    push @$results, join '', map {
      defined $_ ?
        do { my $v = int(($_-$min)/$scale);
        $enc[int($v/$num_enc)].$enc[int($v%$num_enc)]
        }
        : '__'
    } @$values;
  }
  return $results;
}

sub x_labels {
  my $self = shift;
  my @l = ();
  my $p = '';
  my $fill = shift || 0;
  my $fmt = shift || $self->xformat;
  my $mod = shift || $self->xmodulo || 1;
  my $skip = shift || $self->xskip || 1;

  my $bands = scalar @{$self->data} - 1;
  my $bwidth = 1/$bands;
  my @bc = ('ffffff', 'cccccc');

  my $fn = ($fmt =~ s/^!// ?
            sub { strftime $_[0], localtime $_[1] } :
            sub { sprintf $_[0], $_[1] });

  my $c = 0;
  my $cb = 0;
  my @fill = ();
  my $curr_band_col = '';
  my $curr_band_width = 0;
  foreach my $x (map { $_->[0] } @{$self->data}) {
    my $l = $fn->($fmt, $x);
    my $s = $l;
    if ($l =~ m/~/) {
      ($l,$s) = split /~/, $l, 2;
    }
    if ($p ne $l && ($c%$skip) == 0 && ($l%$mod) == 0) {
      push @l, $p eq '' ? '' : $s;
      $cb++;
    } else {
      push @l, '';
    }
    my $new_band_col = $bc[$cb % scalar @bc];
    if ($curr_band_col ne $new_band_col) {
      push @fill, $curr_band_col.','.(sprintf '%.6f',$curr_band_width)
        if ($curr_band_width);
      $curr_band_width = 0;
      $curr_band_col = $new_band_col;
    }
    $curr_band_width += $bwidth;
    $c++;
    $p = $l;
  }
  push @fill, $curr_band_col.','.(sprintf '%.6f',$curr_band_width)
    if ($curr_band_width);

  $self->fill('chf=c,ls,0,'.(join ',', @fill)) if ($fill);
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
