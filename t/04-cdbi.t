#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
use Test::More tests => 33;
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

use_ok('ZenAH::CDBI');

my $device = ZenAH::CDBI::Device->retrieve(1);
ok($device, 'device retrieve(1)');
is($device->attribute('unit'), 'l1', 'device->attribute("valid")');
is($device->attribute('invalid'), undef, 'device->attribute("invalid")');
my $device_attr = ZenAH::CDBI::DeviceAttribute->retrieve(1);
ok($device_attr, 'device_attribute retrieve(1)');
$device_attr->value('');
is($device_attr->update, 1, 'device_attribute->update');
is($device->attribute('unit'), '', 'device->attribute("valid") null');

$device_attr->value('l1');
$device_attr->update();
is($device->action('on'),
   "  xpl -m xpl-cmnd -c x10.basic device=l1 command=on\n",
   'device->action("on")');
my $device_ctrl = ZenAH::CDBI::DeviceControl->search(class => 'x10',
                                                     name => 'on')->first;
$device_ctrl->definition('[% IF false %]');
$device_ctrl->update();
is($device->action('on'),
   "error bad template, on, on device, l_bed_1\n",
   'device->action("on") w/bad template');

is($device->action('invalid'),
   "error invalid action, invalid, on device, l_bed_1\n",
   'device->action("invalid")');

$device->class('Button');
$device->update();
is($device->action('button'),
   'xpl -m xpl-trig -c remote.basic device=l_bed_1 keys=button',
   'device->action("button")');

ok($device_attr = ZenAH::CDBI::DeviceAttribute->create({name => 'base',
                                                       value => '13'}),
   'device_attribute create');
ok(ZenAH::CDBI::DeviceAttributeLink->create({device => $device,
                                             device_attribute => $device_attr}),
   'device_attribute_link create');
$device->class('DMX');
$device->update();
is($device->action('red'),
   'xpl -m xpl-cmnd -c dmx.basic base=13 class=set value=red',
   'device->action("red")');

my $room = ZenAH::CDBI::Room->retrieve(1);
ok($room, 'room retrieve(1)');
is($room->attribute('zone'), 'downstairs', 'room->attribute("valid")');
is($room->attribute('invalid'), undef, 'room->attribute("invalid")');
my $room_attr = ZenAH::CDBI::RoomAttribute->retrieve(2);
ok($room_attr, 'room_attribute retrieve(1)');
$room_attr->value('');
is($room_attr->update, 1, 'room_attribute->update');
is($room->attribute('zone'), '', 'room->attribute("valid") null');

delete $ENV{HARNESS_ACTIVE}; # pretend we are not testing to exercise real code
my $rule = ZenAH::CDBI::Rule->retrieve(1);
is($rule->update, -1, 'rule->update - no change');
is($rule->mtime, '2007-08-05 14:52:24', 'mtime before');
$rule->ftime(time);
is($rule->update, 1, 'rule->update - change ftime');
is($rule->mtime, '2007-08-05 14:52:24', 'mtime after ftime change');
$rule->name('chime');
is($rule->update, 1, 'rule->update - change name');
isnt($rule->mtime, '2007-08-05 14:52:24', 'mtime after name change');

my $temp = ZenAH::CDBI::Template->create({name => 'time',
                                          mtime => 1199145600});
ok($temp, 'template create - w/mtime');
is($temp->mtime->epoch, 1199145600, 'template mtime');
is($temp->update, -1, 'template->update - no change');
is($temp->mtime->epoch, 1199145600, 'template mtime unchanged');
is($temp->text(), undef, 'template->text undefined');
is($temp->to_view('text'), '', 'template->to_view undefined');

is(ref ZenAH::CDBI::loader(), 'Class::DBI::Loader::SQLite',
   'why is this sub here???');
