#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
use Test::More tests => 9;
use t::Helpers qw/test_warn test_error/;

END {
  unlink 't/zenah.db';
}

BEGIN {
  $ENV{ZENAH_DBI_CONFIG}='t/dbi.conf';
  unlink 't/zenah.db';
  0 == system 'sqlite3 t/zenah.db <zenah.sample.sql3' or
    die "sqlite3 failed to create database: $! $@\n";
}

use_ok('ZenAH::Templates');

my $templates = ZenAH::Templates->new();
ok($templates, 'ZenAH::Templates->new()');

my $t;
my @t;
is(test_warn(sub { $t = $templates->_template_content('invalid'); }),
   "ZenAH::Template: can't find: invalid\n", 'invalid in scalar context');
ok(!$t, 'invalid in scalar context - result');

is(test_warn(sub { @t = $templates->_template_content('invalid'); }),
   "ZenAH::Template: can't find: invalid\n", 'invalid in array context');
ok(!$t[0], 'invalid in array context - result');
is($t[1], 'invalid: not found', 'invalid in array context - reason');
ok($t[2] < time + 3 && $t[2] > time - 3, 'invalid in array context - time');

is($templates->_template_content('html/footer'),
   qq{<!-- BEGIN footer -->\r
<div id="copyright">\&copy; [% site.copyright %]</div>\r
<!-- END footer -->\r
}, 'valid in scalar context');
