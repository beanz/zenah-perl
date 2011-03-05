#!/usr/bin/perl -w
#
# Copyright (C) 2005, 2008 by Mark Hindess

use strict;
use English qw/-no_match_vars/;
use FileHandle;
my @modules;

END {
  unlink 't/zenah.db';
}

BEGIN {
  $ENV{ZENAH_DBI_CONFIG}='t/dbi.conf';
  unlink 't/zenah.db';
  0 == system 'sqlite3 t/zenah.db <zenah.sample.sql3' or
    die "sqlite3 failed to create database: $! $@\n";

  my $fh = FileHandle->new('<MANIFEST') or
    die 'Open of MANIFEST failed: '.$ERRNO;
  while(<$fh>) {
    next if (!/^lib\/(.*)\.pm/);
    my $m = $LAST_PAREN_MATCH;
    $m =~ s!/!::!g;
    push @modules, $m;
  }
  $fh->close;
  require Test::More;
  import Test::More tests => scalar @modules;
}

foreach my $m (@modules) {
 SKIP: {
    if ($m eq 'ZenAH' or $m eq 'ZenAH::View::Site') {
      require_ok('Catalyst');
      import Catalyst $m;
    } else {
      require_ok($m);
    }
  }
}
