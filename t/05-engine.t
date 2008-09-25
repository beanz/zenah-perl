#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
use Test::More tests => 2;
use t::Helpers qw/test_warn test_error/;

END {
  unlink 't/zenah.db';
}

BEGIN {
  $ENV{ZENAH_DBI_CONFIG}='t/dbi.conf';
  unlink 't/zenah.db';
  0 == system 'sqlite3 t/zenah.db <zenah.sample.sql3' or
    die "sqlite3 failed to create database: $! $@\n";

  $ENV{LATITUDE} = 51;
  $ENV{LONGITUDE} = -1;
}

use_ok('ZenAH::Engine');

my $engine = ZenAH::Engine->new(ip => "127.0.0.1",
                                broadcast => "127.0.0.1");
ok($engine);

$engine->main_loop(1);
