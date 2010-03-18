#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
use POSIX qw/strftime/;
use Test::More tests => 76;
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

my $schema = $engine->{_db};

$engine->main_loop(1);
my $count = $engine->timer_callback_count('rules_timer');

# Check if rule is removed when disabled
my $cuckoo = $schema->resultset('Rule')->single({ name => 'cuckoo' });
ok($engine->exists_rule($cuckoo), 'rule "cuckoo" found');
$engine->disable_rule($cuckoo);

$engine->reset_timer(rules_timer => time - 120);
$engine->main_loop(1);
is($engine->timer_callback_count('rules_timer'), ++$count, 'rules read(1)');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" removed');

# Check if rule is not added when the trigger type is invalid
$cuckoo->type('invalid');
$cuckoo->update();
$engine->disable_rule($cuckoo);
is(test_warn(sub { $engine->enable_rule($cuckoo) }),
   "unknown trigger type: invalid cuckoo\n", 'invalid trigger type');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" not added (invalid)');

# Check if rule is not added when the trigger type is null
$cuckoo->type('');
$cuckoo->update();
$engine->disable_rule($cuckoo);
is(test_warn(sub { $engine->enable_rule($cuckoo) }),
   "empty trigger type: cuckoo\n", 'null trigger type');
ok(!$engine->exists_rule($cuckoo), 'rule "cuckoo" not added (null)');
# Check if rule is not added when the trigger type is null

# re-add rule with faster trigger time
$cuckoo->type('at');
$cuckoo->trig('1');
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);
ok($engine->exists_rule($cuckoo), 'rule "cuckoo" added');
my $dusk = $schema->resultset('Rule')->single({ name => 'dusk' });
$engine->disable_rule($dusk);
ok(!$engine->exists_rule($dusk), 'rule "dusk" disabled');


# test actions
$engine->disable_rule($cuckoo);
$cuckoo->action(qq{
invalid action
# comment
enable dusk
disable cleaner_prep
sleep 1
debug [% zenah.datetime.ymd %]
error argh
});
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);

is(test_warn(sub {
               my $count =
                 $engine->timer_callback_count('trigger-for-rule-'.$cuckoo);
               while ($engine->timer_callback_count('trigger-for-rule-'.
                                                    $cuckoo) == $count) {
                 $engine->main_loop(1);
               }
             }), 'no action defined for \'invalid\'', 'ran new rule');
$engine->disable_rule($cuckoo);
ok($engine->exists_rule($dusk), 'rule "dusk" enabled');
my $cleaner_prep = 
  $schema->resultset('Rule')->single({ name => 'cleaner_prep' });
ok(!$engine->exists_rule($cleaner_prep), 'rule "cleaner_prep" disabled');

my $sleeper;
foreach ($engine->timers) {
  if (/^~tmp~sleep~/) {
    $sleeper= $_;
  }
}
isnt($sleeper, undef, 'sleep rule is present');
die "no point carrying on\n" unless ($sleeper);

ok($engine->exists_timer($sleeper), 'sleeper is present');
is(test_warn(sub {
               while ($engine->exists_timer($sleeper)) {
                 $engine->main_loop(1)
               }
             }), strftime("%Y-%m-%d", localtime time)."\nError: argh\n", 'sleeper awoke');

$cuckoo->action(qq{
enable
enable invalid
disable
disable invalid
sleep
debug
error
scene
xpl
device
device invalid
sleep 1
});
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);

my $warn =
  test_warn(sub {
              my $count =
                $engine->timer_callback_count('trigger-for-rule-'.$cuckoo);
              while ($engine->timer_callback_count('trigger-for-rule-'.
                                                   $cuckoo) == $count) {
                $engine->main_loop(1);
              }
            });
$warn =~ s/\s+at .*?\s+line\s+\d+//msg;
is($warn, q{ZenAH::Engine->action_enable_rule: requires 'spec' parameter
ZenAH::Engine->action_enable_rule: no rule with name: invalid
ZenAH::Engine->action_disable_rule: requires 'spec' parameter
ZenAH::Engine->action_disable_rule: no rule with name: invalid
ZenAH::Engine->action_sleep: requires 'spec' parameter
ZenAH::Engine->action_debug: requires 'spec' parameter
ZenAH::Engine->action_error: requires 'spec' parameter
ZenAH::Engine->action_scene: requires 'spec' parameter
ZenAH::Engine->action_xpl: requires 'spec' parameter
ZenAH::Engine->action_device: requires 'spec' parameter
ZenAH::Engine->action_device: device, invalid, not found
ZenAH::Engine->action_sleep: sleep for nothing?},
   'ran modified rule');



$cuckoo->action(qq{
debug stash
debug ...
this is a test
error
scene
xpl
});
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);

$warn =
  test_warn(sub {
              my $count =
                $engine->timer_callback_count('trigger-for-rule-'.$cuckoo);
              while ($engine->timer_callback_count('trigger-for-rule-'.
                                                   $cuckoo) == $count) {
                $engine->main_loop(1);
              }
            });
$warn =~ s/\s+at .*?\s+line\s+\d+//msg;
is($warn, q!------------------------------------------------------------------------------
$stash = {};

------------------------------------------------------------------------------
------------------------------------------------------------------------------
this is a test
error
scene
xpl

------------------------------------------------------------------------------
!,
   'ran debug rule');


my $kettle_warn =
  $schema->resultset('Rule')->single({ name => 'kettle_warn' });
ok(!$engine->exists_rule($kettle_warn), 'rule "kettle_warn" disabled');

$cuckoo->action('scene kettle state=on');
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);

$count =
  $engine->timer_callback_count('trigger-for-rule-'.$cuckoo);
while ($engine->timer_callback_count('trigger-for-rule-'.
                                     $cuckoo) == $count) {
  $engine->main_loop(1);
}

ok($engine->exists_rule($kettle_warn), 'rule "kettle_warn" enabled');

delete $ENV{HARNESS_ACTIVE};
$cuckoo->action('scene name=kettle state=off');
$cuckoo->update();
$engine->disable_rule($cuckoo);
$engine->enable_rule($cuckoo);
$engine->reset_timer(rules_timer => time - 120);

while ($engine->timer_callback_count('trigger-for-rule-'.
                                     $cuckoo) != 1) {
  $engine->main_loop(1);
}

ok(!$engine->exists_rule($kettle_warn), 'rule "kettle_warn" enabled');

$engine->disable_rule($cuckoo);

# remove a scene rule
my $kettle =
  $schema->resultset('Rule')->single({ name => 'kettle' });
ok($engine->exists_rule($kettle), 'rule "kettle" enabled');
$engine->disable_rule($kettle);
ok(!$engine->exists_rule($kettle), 'rule "kettle" disabled');

# remove an xpl rule
my $light_state =
  $schema->resultset('Rule')->single({ name => 'light_state' });
ok($engine->exists_xpl_callback('trigger-for-rule-'.$light_state),
   'rule "light_state" enabled');
$engine->disable_rule($light_state);
ok(!$engine->exists_xpl_callback('trigger-for-rule-'.$light_state),
   'rule "light_state" disabled');

my $test_rule =
  $schema->resultset('Rule')->create({
                                      name => 'test',
                                      type => 'at',
                                      trig => '100',
                                      action => 'debug test',
                                     });
ok($test_rule, 'test_rule added to db');
$engine->enable_rule($test_rule);

sub process_test_rule {
  my $action = shift;
  my $stash = shift || {};
  $test_rule->update({ action => $action ? "debug ...\n".$action : $action })
    or return;
  $engine->disable_rule($test_rule);
  $engine->enable_rule($test_rule) or return;
  my $res =
    $engine->process_template($engine->rule_template_document($test_rule),
                              $stash);
  $res =~ s/^debug \.\.\.\n//;
  return $res;
}

# test device stash
is(process_test_rule(q{
[% FOREACH dev = zenah.device.all -%]
[% dev.name %]
[% END -%]
}),
   q{
a_amp
a_plasma
a_tv
b_bath
b_bed_1
c_bed_1
c_kitchen
c_lounge
l_bath
l_bed_1
l_bed_1_r
l_cloak
l_garden
l_kitchen
l_kitchen_under
l_lounge
m_bath
m_bath_l
m_bed_1
m_bed_1_l
m_cloak
m_cloak_l
m_kitchen
m_kitchen_l
m_lounge
m_lounge_l
},
   'device.all stash');

is(process_test_rule(q{
[% FOREACH dev = zenah.device.by_type_list("Curtain") -%]
[% dev.name %]
[% END -%]
}),
   qq{
c_bed_1
c_kitchen
c_lounge
},
   'device.by_type_list stash');

is(process_test_rule('[% zenah.device.by_attr("unit", "a2").name -%]'),
   'a_amp', 'device.by_attr stash');

is(process_test_rule('[% zenah.device.by_attr("unit", "n0").name -%]'),
   '', 'device.by_attr stash - not found');

is(process_test_rule(
     '[% zenah.device.by_type_and_attr("X10App", "unit", "a2").name -%]'),
   'a_amp', 'device.by_type_and_attr stash');

is(process_test_rule(q{
[% FOREACH dev = zenah.device.by_attr_list("unit", "a2") -%]
[% dev.name %]
[% END -%]
}),
   "\na_amp\n", 'device.by_attr_list stash');

is(process_test_rule(q{
[% FOREACH dev = zenah.device.by_attr_list("unit", "n0") -%]
[% dev.name %]
[% END -%]
}),
   "\n", 'device.by_attr_list stash - not found');

is(process_test_rule(q{
[% FOREACH dev = zenah.device.by_attr_name_list("open_relay") -%]
[% dev.name %]
[% END -%]
}),
   q{
b_bath
c_bed_1
b_bed_1
c_kitchen
c_lounge
},
 'device.by_attr_name_list stash');

is(process_test_rule(q{
[% zenah.map.lookup("x10lamp_trigger", "b1") %]
}),
   q{
l_bed_1
},
 'map.lookup stash');

is(process_test_rule(q{
[% zenah.map.lookup("x10lamp_trigger", "b4") -%]
}),
   q{
},
 'map.lookup stash - not found');

is(process_test_rule(q{
[% zenah.map.reverse("x10lamp_trigger", "l_bed_1") %]
}),
   q{
b1
},
 'map.reverse stash');

is(process_test_rule(q{
[% zenah.map.reverse("x10lamp_trigger", "l_garage") -%]
}),
   q{
},
 'map.reverse stash - not found');

is(process_test_rule(q{
[% FOREACH val = zenah.map.lookup_list("x10lamp_trigger", "b1") -%]
[% val %]
[% END -%]
}),
   q{
l_bed_1
},
 'map.lookup_list stash');

is(process_test_rule(q{
[% FOREACH val = zenah.map.reverse_list("x10lamp_trigger", "l_bed_1") -%]
[% val %]
[% END -%]
}),
   q{
b1
},
 'map.reverse_list stash');

is(process_test_rule(q{
[% FOREACH entry = zenah.map.all("x10lamp_trigger") -%]
[% entry.name %] = [% entry.value %]
[% END -%]
}),
   q{
b1 = l_bed_1
b2 = l_bed_1_r
b3 = l_bath
},
 'map.all stash');

is(process_test_rule(q{
[% zenah.rrd.get() %]
}),
   q{
not implemented
},
 'rrd.get stash');

is(process_test_rule(q{
[% FOREACH room = zenah.room.all() -%]
[% room.name %]
[% END -%]
}),
   q{
bath
bed_1
cloak
garden
kitchen
lounge
},
 'room.all stash');

is(process_test_rule(q{
[% zenah.room.by_attr("zone", "Outside").name %]
}),
   q{
garden
},
 'room.by_attr stash');

is(process_test_rule(q{
[% zenah.room.by_attr("zone", "invalid").name -%]
}),
   q{
},
 'room.by_attr stash - invalid');

is(process_test_rule(q{
[% FOREACH room = zenah.room.by_attr_list("zone", "Upstairs") -%]
[% room.name %]
[% END -%]
}),
   q{
bath
bed_1
},
 'room.by_attr_list stash');

is(process_test_rule(q{
[% FOREACH room = zenah.room.by_attr_list("zone", "invalid") -%]
[% room.name %]
[% END -%]
}),
   q{
},
 'room.by_attr_list stash - not found');

is(process_test_rule(q{[% zenah.state.get("uv", "uv138.55").value %]}),
   q{2},
   'state.get stash');

is(process_test_rule(q{[% zenah.state.get_value("uv", "uv138.55") %]}),
   q{2},
   'state.get_value stash');

is(process_test_rule(q{[% zenah.state.get_value("uv", "invalid") %]}),
   q{},
   'state.get_value stash - invalid');

is(process_test_rule(q{
[% FOREACH state = zenah.state.get_by_type("light") -%]
[% state.name %] = [% state.value %]
[% END -%]
}),
   q{
bath = light
bed_1 = light
kitchen = light
cloak = light
lounge = light
},
   'state.get_by_type stash');

is(process_test_rule(q{
[% FOREACH state = zenah.state.get_by_type_matching("light", "^b") -%]
[% state.name %] = [% state.value %]
[% END -%]
}),
   q{
bath = light
bed_1 = light
},
   'state.get_by_type_matching stash');

is(process_test_rule(q{
[% FOREACH state = zenah.state.get_by_type_since("light", 1186322165) -%]
[% state.name %] = [% state.value %]
[% END -%]
}),
   q{
lounge = light
},
   'state.get_by_type_since stash');

is(process_test_rule(q{
[% FOREACH state = zenah.state.get_by_type_since_matching("light", 1186322150, "^c") -%]
[% state.name %] = [% state.value %]
[% END -%]
}),
   q{
cloak = light
},
   'state.get_by_type_since_matching stash');

is(process_test_rule(q{
[% FOREACH value = zenah.state.get_values_by_type("light") -%]
[% value %]
[% END -%]
}),
   q{
light
light
light
light
light
},
   'state.get_values_by_type stash');

is(process_test_rule(q{
[% FOREACH value = zenah.state.get_values_by_type_matching("light", "^b") -%]
[% value %]
[% END -%]
}),
   q{
light
light
},
   'state.get_values_by_type_matching stash');

is(process_test_rule(q{
[% FOREACH value = zenah.state.get_values_by_type_since("light", 1186322165) -%]
[% value %]
[% END -%]
}),
   q{
light
},
   'state.get_values_by_type_since stash');

is(process_test_rule(q{
[% FOREACH value = zenah.state.get_values_by_type_since_matching("light", 1186322150, "^c") -%]
[% value %]
[% END -%]
}),
   q{
light
},
   'state.get_values_by_type_since_matching stash');

is(process_test_rule(q{
[% zenah.state.set("light", "garden", "light") %]
[% zenah.state.get_value("light","garden") %]
[% zenah.state.set("uv", "uv138.55", 0) %]
[% zenah.state.get_value("uv","uv138.55") %]
}),
   q{
light
light
0
0
},
   'state.set stash');

my $state =
  $schema->resultset('State')->single({ type => 'uv', name => 'uv138.55' });
my $ctime = $state->ctime;
my $mtime = $state->mtime;
sleep 2;

is(process_test_rule(q{
[% zenah.state.set("uv", "uv138.55", 0) %]
}),
   q{
0
},
   'state.set stash - mtime change');

$state->discard_changes();
my $new_mtime = $state->mtime;
ok($new_mtime > $mtime, 'state.set stash - mtime changed');
my $new_ctime = $state->ctime;
is($new_ctime, $ctime, 'state.set stash - ctime unchanged');

is($engine->info("output\n"), 0, 'engine->info not verbose');
my $engine2 = $engine->new(ip => "127.0.0.1",
                           broadcast => "127.0.0.1",
                           verbose => 1, tz => 'Europe/Vienna');
is($engine2->info("output\n"), 1, 'engine->info verbose');
is(ref $engine2->{_plugin}->{Timer}->{_tz},
   'DateTime::TimeZone::Europe::Vienna',
   'engine->new tz param');
$ENV{TZ}='Europe/Moscow';
$engine2 = $engine->new(ip => "127.0.0.1",
                        broadcast => "127.0.0.1");
is(ref $engine->{_plugin}->{Timer}->{_tz},
   'DateTime::TimeZone::Europe::London',
   'engine->new tz default');
is(ref $engine2->{_plugin}->{Timer}->{_tz},
   'DateTime::TimeZone::Europe::Moscow',
   'engine->new tz environment var');

$cuckoo->trig('invalid');
$cuckoo->update();
$engine->disable_rule($cuckoo);
is(test_warn(sub { $engine->enable_rule($cuckoo); }),
   q{Failed to add rule cuckoo: xPL::Timer->new: Failed to load }.
     q{xPL::Timer::invalid: Can't locate xPL/Timer/invalid.pm in @INC},
   'failing to add rule without crashing');

# Some error/warning cases not already covered

is(test_error(sub { $engine->add_trigger() }),
   'ZenAH::Engine->add_trigger: requires \'type\' argument',
   'add_trigger error');

is(test_error(sub { $engine->add_action() }),
   'ZenAH::Engine->add_action: requires \'type\' argument',
   'add_action error');

is(test_error(sub { $engine->add_stash('datetime' => 'test') }),
   'ZenAH::Engine->add_stash: '.
     'plugin bug: stash element \'datetime\' already exists',
   'add_stash error');

is(test_warn(sub { process_test_rule() }),
   'ZenAH::Engine->read_rule: Action template is empty',
   'empty template warning');

is(test_warn(sub { process_test_rule('[% IF false %]') }),
   'ZenAH::Engine->read_rule: Action template parse error: line 2: '.
     'unexpected end of input',
   'template syntax error');

is(test_warn(sub { $engine->trigger_rule_by_name('invalid') }),
   'ZenAH::Engine->trigger_rule_by_name: no rule with name: invalid',
   'triggering non-existent rule');

is(test_warn(sub { $engine->run_action('device l_bed_1 change_bulb') }),
   "Error: invalid action, change_bulb, on device, l_bed_1\n",
   'device plugin run_action');
