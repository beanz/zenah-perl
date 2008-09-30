#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
use Test::More tests => 17;
use t::Helpers qw/test_error test_warn/;

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
my $count = $engine->timer_callback_count('rules_timer');

# Check if rule is removed when disabled
my $cuckoo = ZenAH::CDBI::Rule->search(name => 'cuckoo')->first;
ok($engine->exists_rule($cuckoo), 'rule "cuckoo" found');
$engine->disable_rule($cuckoo);

$engine->reset_timer(rules_timer => time - 120);
$engine->main_loop(1);
is($engine->timer_callback_count('rules_timer'), ++$count, 'rules read(1)');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" removed');

# Check if rule is not added when the trigger type is invalid
$cuckoo->trig_type('invalid');
$cuckoo->update();
is(test_warn(sub { $engine->enable_rule($cuckoo) }),
   "unknown trigger type: invalid cuckoo\n", 'invalid trigger type');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" not added (invalid)');

# Check if rule is not added when the trigger type is null
$cuckoo->trig_type('');
$cuckoo->update();
is(test_warn(sub { $engine->enable_rule($cuckoo) }),
   "empty trigger type: cuckoo\n", 'null trigger type');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" not added (null)');
# Check if rule is not added when the trigger type is null

# re-add rule with faster trigger time
$cuckoo->trig_type('at');
$cuckoo->trig('1');
$cuckoo->update();
$engine->enable_rule($cuckoo);
ok($engine->exists_rule($cuckoo), 'rule "cuckoo" added');
my $dusk = ZenAH::CDBI::Rule->search(name => 'dusk')->first;
$engine->disable_rule($dusk);
ok(!$engine->exists_rule($dusk), 'rule "dusk" disabled');


# test actions
$cuckoo->action(qq{
invalid action
# comment
enable dusk
disable cleaner_prep
sleep 1
debug testing 1 2 3
error argh
});
$cuckoo->update();
$engine->enable_rule($cuckoo);

is(test_warn(sub {
               my $count =
                 $engine->timer_callback_count('trigger-for-rule-'.$cuckoo);
               while ($engine->timer_callback_count('trigger-for-rule-'.
                                                    $cuckoo) == $count) {
                 $engine->main_loop(1)
               }
             }), 'no action defined for \'invalid\'', 'ran new rule');
$engine->disable_rule($cuckoo);
ok($engine->exists_rule($dusk), 'rule "dusk" enabled');
my $cleaner_prep =
  ZenAH::CDBI::Rule->search(name => 'cleaner_prep')->first;
ok(!$engine->exists_rule($cleaner_prep), 'rule "dusk" disabled');

my $sleeper;
foreach ($engine->timers) {
  if (/^~tmp~sleep~/) {
    $sleeper= $_;
  }
}
isnt($sleeper, undef, 'sleep rule is present');
ok($engine->exists_timer($sleeper), 'sleeper is present');
is(test_warn(sub {
               while ($engine->exists_timer($sleeper)) {
                 $engine->main_loop(1)
               }
             }), "testing 1 2 3\nError: argh\n", 'sleeper awoke');
