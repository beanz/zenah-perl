#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
my %request;
my $has_test_difference;

END {
  unlink 't/zenah.db';
}

BEGIN {
  $ENV{ZENAH_DBI_CONFIG}='t/dbi.conf';
  unlink 't/zenah.db';
  0 == system 'sqlite3 t/zenah.db <zenah.sample.sql3' or
    die "sqlite3 failed to create database: $! $@\n";
  sub read_request_data {
    my ($dir, $req) = @_;
    my $rd = 't/'.$dir;
    my $dh = DirHandle->new('t/'.$dir) or
      die "Open of t/$dir directory: $ERRNO\n";
    foreach (sort $dh->read) {
      next if (/^\./);
      if (-d $rd.'/'.$_) {
        read_request_data($dir.'/'.$_, $req);
        next;
      }
      next if (!/^(.*)\.txt$/);
      my $name = $LAST_PAREN_MATCH;
      my $f = $rd.'/'.$_;
      my $fh = FileHandle->new($f) or die "Failed to open $f: $ERRNO\n";
      local $RS;
      undef $RS;
      $req->{$dir.'/'.$name} = <$fh>;
      $fh->close;
    }
    $dh->close;
  }
  my $dir = $ENV{ZENAH_ADMIN_TEST_DIR} || 'admin';
  read_request_data($dir, \%request);
  require Test::More;
  import Test::More tests => (1+3*(scalar keys %request));
  eval { require Test::Differences; import Test::Differences; };
  $has_test_difference = !$@;
}

use_ok 'Catalyst::Test', 'ZenAH';

foreach my $file (keys %request) {
  my $m = join '::', map { ucfirst $_ } (split /\//, $file, 3)[0,1];
  $m =~ s/attribute/Attribute/;
  $m =~ s/control/Control/;
  my $cont = 'ZenAH::Controller::'.$m;
  require_ok $cont;
  my $req = '/'.$file;
  my $resp = request($req);
  ok($resp->is_success, $req.' - is success');
  my $got = squash_whitespace($resp->content."\n");
  my $expected = squash_whitespace($request{$file});
  if ($has_test_difference) {
    eq_or_diff $got, $expected, $req.' - content';
  } else {
    is($got, $expected, $req.' - content');
  }
}

sub squash_whitespace {
  my $s = $_[0];
  $s =~ s/\n\s*\n/\n/g;
  $s =~ s/^\s+//mg;
  $s;
}
