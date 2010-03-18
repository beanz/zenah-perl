package ZenAH::DBIC;

use strict;
use warnings;
use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes();

sub schema {

  my %args;
  my $config = exists $ENV{ZENAH_DBI_CONFIG} ? $ENV{ZENAH_DBI_CONFIG} :
    -f 'zenah.dbi.conf' ? 'zenah.dbi.conf' : undef;
  open my $fh, $config or
    die "Failed to open database configuration, $config: $!\n".
      "Try setting the environment variable ZENAH_DBI_CONFIG.";
  while (<$fh>) {
    next if (/^#/ or /^\s*$/);
    chomp;
    my ($key, $val) = split /\s+[=:]\s+/, $_, 2;
    $args{$key} = $val;
  }
  close $fh;
  my ($dsn, $user, $pass) = @args{qw/dsn user pass/};
  delete $args{$_} foreach (qw/dsn user pass/);
  return __PACKAGE__->connect($dsn, $user, $pass, \%args);
}

1;
