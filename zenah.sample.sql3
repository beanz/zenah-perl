BEGIN TRANSACTION;
CREATE TABLE "device" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "string" varchar(80) default NULL,
  "description" text,
  "type" varchar(80) default NULL
);
INSERT INTO "device" VALUES(1,'l_bed_1','Light','Main light','X10Lamp');
INSERT INTO "device" VALUES(2,'l_bath','Light','Main Light','X10Lamp');
INSERT INTO "device" VALUES(3,'l_kitchen','Spots','Main Lights','X10Lamp');
INSERT INTO "device" VALUES(4,'l_bed_1_r','Reading Light','Bedside Light','X10Lamp');
INSERT INTO "device" VALUES(5,'l_lounge','Light','Main Light','X10Lamp');
INSERT INTO "device" VALUES(6,'l_kitchen_under','Under Lights','Under Cabinet Lights','X10Lamp');
INSERT INTO "device" VALUES(7,'l_cloak','Light','Main light','X10Lamp');
INSERT INTO "device" VALUES(8,'l_garden','Light','Security Light','X10Lamp');
INSERT INTO "device" VALUES(9,'b_bath','Blind','Blind','Blind');
INSERT INTO "device" VALUES(10,'c_bed_1','Curtain','Curtain','Curtain');
INSERT INTO "device" VALUES(11,'b_bed_1','Blind','Blind','Blind');
INSERT INTO "device" VALUES(12,'c_kitchen','Curtain','Curtain','Curtain');
INSERT INTO "device" VALUES(13,'c_lounge','Curtain','Curtain','Curtain');
INSERT INTO "device" VALUES(14,'m_bath','Motion','X10 motion sensor','X10Motion');
INSERT INTO "device" VALUES(15,'m_bath_l','Light Sensor','X10 light sensor','X10Light');
INSERT INTO "device" VALUES(16,'m_bed_1','Motion','X10 motion sensor','X10Motion');
INSERT INTO "device" VALUES(17,'m_bed_1_l','Light Sensor','X10 light sensor','X10Light');
INSERT INTO "device" VALUES(18,'m_kitchen','Motion','X10 motion sensor','X10Motion');
INSERT INTO "device" VALUES(19,'m_cloak','Motion','X10 motion sensor','X10Motion');
INSERT INTO "device" VALUES(20,'m_lounge','Motion','X10 motion sensor','X10Motion');
INSERT INTO "device" VALUES(21,'m_kitchen_l','Light Sensor','X10 light sensor','X10Light');
INSERT INTO "device" VALUES(22,'m_cloak_l','Light Sensor','X10 light sensor','X10Light');
INSERT INTO "device" VALUES(23,'m_lounge_l','Light Sensor','X10 light sensor','X10Light');
INSERT INTO "device" VALUES(24,'a_plasma','Plasma','Plasma TV','X10App');
INSERT INTO "device" VALUES(25,'a_amp','Amplifier','Amplifier','X10App');
INSERT INTO "device" VALUES(26,'a_tv','TV','Plasma TV and Amplifier combined device','X10App');
CREATE TABLE "device_attribute" (
  "id" integer PRIMARY KEY,
  "name" varchar(30) default NULL,
  "value" varchar(200) default NULL
);
INSERT INTO "device_attribute" VALUES(1,'unit','l1');
INSERT INTO "device_attribute" VALUES(2,'unit','l2');
INSERT INTO "device_attribute" VALUES(3,'unit','l3');
INSERT INTO "device_attribute" VALUES(4,'unit','k1');
INSERT INTO "device_attribute" VALUES(5,'unit','k2');
INSERT INTO "device_attribute" VALUES(6,'unit','k3');
INSERT INTO "device_attribute" VALUES(7,'unit','k4');
INSERT INTO "device_attribute" VALUES(8,'unit','k5');
INSERT INTO "device_attribute" VALUES(9,'unit','j1');
INSERT INTO "device_attribute" VALUES(10,'open_relay','o01');
INSERT INTO "device_attribute" VALUES(11,'open_relay','o03');
INSERT INTO "device_attribute" VALUES(12,'open_relay','o05');
INSERT INTO "device_attribute" VALUES(13,'open_relay','o07');
INSERT INTO "device_attribute" VALUES(14,'open_relay','o09');
INSERT INTO "device_attribute" VALUES(15,'close_relay','o02');
INSERT INTO "device_attribute" VALUES(16,'close_relay','o04');
INSERT INTO "device_attribute" VALUES(17,'close_relay','o06');
INSERT INTO "device_attribute" VALUES(18,'close_relay','o08');
INSERT INTO "device_attribute" VALUES(19,'close_relay','o10');
INSERT INTO "device_attribute" VALUES(20,'unit','m2');
INSERT INTO "device_attribute" VALUES(21,'unit','m3');
INSERT INTO "device_attribute" VALUES(22,'unit','m1');
INSERT INTO "device_attribute" VALUES(23,'unit','m4');
INSERT INTO "device_attribute" VALUES(24,'unit','m5');
INSERT INTO "device_attribute" VALUES(25,'unit','m6');
INSERT INTO "device_attribute" VALUES(26,'unit','m7');
INSERT INTO "device_attribute" VALUES(27,'unit','m9');
INSERT INTO "device_attribute" VALUES(28,'unit','m8');
INSERT INTO "device_attribute" VALUES(29,'unit','m10');
INSERT INTO "device_attribute" VALUES(30,'unit','a1');
INSERT INTO "device_attribute" VALUES(31,'unit','a2');
INSERT INTO "device_attribute" VALUES(32,'unit','a3');
INSERT INTO "device_attribute" VALUES(33,'unit','a2,a3');
CREATE TABLE "device_attribute_link" (
  "id" integer PRIMARY KEY,
  "device" int(11) default NULL,
  "device_attribute" int(11) default NULL
);
INSERT INTO "device_attribute_link" VALUES(1,1,1);
INSERT INTO "device_attribute_link" VALUES(2,2,2);
INSERT INTO "device_attribute_link" VALUES(3,3,4);
INSERT INTO "device_attribute_link" VALUES(4,4,3);
INSERT INTO "device_attribute_link" VALUES(5,5,6);
INSERT INTO "device_attribute_link" VALUES(6,6,5);
INSERT INTO "device_attribute_link" VALUES(7,7,7);
INSERT INTO "device_attribute_link" VALUES(8,8,9);
INSERT INTO "device_attribute_link" VALUES(9,9,10);
INSERT INTO "device_attribute_link" VALUES(10,9,15);
INSERT INTO "device_attribute_link" VALUES(11,10,11);
INSERT INTO "device_attribute_link" VALUES(12,10,16);
INSERT INTO "device_attribute_link" VALUES(13,11,12);
INSERT INTO "device_attribute_link" VALUES(14,11,17);
INSERT INTO "device_attribute_link" VALUES(15,12,13);
INSERT INTO "device_attribute_link" VALUES(16,12,18);
INSERT INTO "device_attribute_link" VALUES(17,13,14);
INSERT INTO "device_attribute_link" VALUES(18,13,19);
INSERT INTO "device_attribute_link" VALUES(19,14,22);
INSERT INTO "device_attribute_link" VALUES(20,15,20);
INSERT INTO "device_attribute_link" VALUES(21,16,21);
INSERT INTO "device_attribute_link" VALUES(22,17,23);
INSERT INTO "device_attribute_link" VALUES(23,18,24);
INSERT INTO "device_attribute_link" VALUES(24,19,26);
INSERT INTO "device_attribute_link" VALUES(25,20,27);
INSERT INTO "device_attribute_link" VALUES(26,21,25);
INSERT INTO "device_attribute_link" VALUES(27,22,28);
INSERT INTO "device_attribute_link" VALUES(28,23,29);
INSERT INTO "device_attribute_link" VALUES(29,25,31);
INSERT INTO "device_attribute_link" VALUES(30,24,32);
INSERT INTO "device_attribute_link" VALUES(31,26,33);
CREATE TABLE "device_control_link" (
  "id" integer PRIMARY KEY,
  "device" int(11) default NULL,
  "device_control" int(11) default NULL
);
INSERT INTO "device_control_link" VALUES(1,1,1);
INSERT INTO "device_control_link" VALUES(2,1,2);
INSERT INTO "device_control_link" VALUES(3,1,3);
INSERT INTO "device_control_link" VALUES(4,1,4);
INSERT INTO "device_control_link" VALUES(5,1,16);
INSERT INTO "device_control_link" VALUES(6,2,1);
INSERT INTO "device_control_link" VALUES(7,2,2);
INSERT INTO "device_control_link" VALUES(8,2,3);
INSERT INTO "device_control_link" VALUES(9,2,4);
INSERT INTO "device_control_link" VALUES(10,2,16);
INSERT INTO "device_control_link" VALUES(11,3,1);
INSERT INTO "device_control_link" VALUES(12,3,2);
INSERT INTO "device_control_link" VALUES(13,3,3);
INSERT INTO "device_control_link" VALUES(14,3,4);
INSERT INTO "device_control_link" VALUES(15,3,16);
INSERT INTO "device_control_link" VALUES(16,4,1);
INSERT INTO "device_control_link" VALUES(17,4,2);
INSERT INTO "device_control_link" VALUES(18,4,3);
INSERT INTO "device_control_link" VALUES(19,4,4);
INSERT INTO "device_control_link" VALUES(20,4,16);
INSERT INTO "device_control_link" VALUES(21,5,1);
INSERT INTO "device_control_link" VALUES(22,5,2);
INSERT INTO "device_control_link" VALUES(23,5,3);
INSERT INTO "device_control_link" VALUES(24,5,4);
INSERT INTO "device_control_link" VALUES(25,5,16);
INSERT INTO "device_control_link" VALUES(26,6,1);
INSERT INTO "device_control_link" VALUES(27,6,2);
INSERT INTO "device_control_link" VALUES(28,6,3);
INSERT INTO "device_control_link" VALUES(29,6,4);
INSERT INTO "device_control_link" VALUES(30,6,16);
INSERT INTO "device_control_link" VALUES(31,7,1);
INSERT INTO "device_control_link" VALUES(32,7,2);
INSERT INTO "device_control_link" VALUES(33,7,3);
INSERT INTO "device_control_link" VALUES(34,7,4);
INSERT INTO "device_control_link" VALUES(35,7,16);
INSERT INTO "device_control_link" VALUES(36,8,1);
INSERT INTO "device_control_link" VALUES(37,8,2);
INSERT INTO "device_control_link" VALUES(40,8,16);
INSERT INTO "device_control_link" VALUES(41,8,17);
INSERT INTO "device_control_link" VALUES(44,10,5);
INSERT INTO "device_control_link" VALUES(45,10,6);
INSERT INTO "device_control_link" VALUES(48,13,5);
INSERT INTO "device_control_link" VALUES(49,13,6);
INSERT INTO "device_control_link" VALUES(50,12,5);
INSERT INTO "device_control_link" VALUES(51,12,6);
INSERT INTO "device_control_link" VALUES(52,25,1);
INSERT INTO "device_control_link" VALUES(53,25,2);
INSERT INTO "device_control_link" VALUES(54,24,1);
INSERT INTO "device_control_link" VALUES(55,24,2);
INSERT INTO "device_control_link" VALUES(56,26,1);
INSERT INTO "device_control_link" VALUES(57,26,2);
INSERT INTO "device_control_link" VALUES(58,9,18);
INSERT INTO "device_control_link" VALUES(59,9,19);
INSERT INTO "device_control_link" VALUES(60,11,18);
INSERT INTO "device_control_link" VALUES(61,11,19);
CREATE TABLE "list" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "liststate" int(11) default NULL
);
CREATE TABLE "listitem" (
  "id" integer PRIMARY KEY,
  "name" text
);
CREATE TABLE "listitemlink" (
  "id" integer PRIMARY KEY,
  "list" int(11) default NULL,
  "listitem" int(11) default NULL
);
CREATE TABLE "liststate" (
  "id" integer PRIMARY KEY,
  "name" varchar(20) default NULL
);
CREATE TABLE "map" (
  "id" integer PRIMARY KEY,
  "type" varchar(50) default NULL,
  "name" varchar(80) default NULL,
  "value" varchar(255) default NULL
);
INSERT INTO "map" VALUES(1,'x10lamp_trigger','b1','l_bed_1');
INSERT INTO "map" VALUES(2,'x10lamp_trigger','b2','l_bed_1_r');
INSERT INTO "map" VALUES(3,'x10lamp_trigger','b3','l_bath');
INSERT INTO "map" VALUES(4,'scene_trigger','b4','kettle');
INSERT INTO "map" VALUES(5,'motion_trigger','cloak','l_cloak');
CREATE TABLE "phone_hist" (
  "id" integer PRIMARY KEY,
  "num" varchar(30) default NULL,
  "ctime" int(11) default NULL
);
CREATE TABLE "room" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "string" varchar(80) default NULL,
  "description" text
);
INSERT INTO "room" VALUES(1,'lounge','Lounge','Main living area');
INSERT INTO "room" VALUES(2,'bed_1','Bedroom 1','Master bedroom');
INSERT INTO "room" VALUES(3,'cloak','Cloak Room','Downstairs toilet');
INSERT INTO "room" VALUES(4,'bath','Bathroom','Bathroom');
INSERT INTO "room" VALUES(5,'kitchen','Kitchen','Kitchen');
INSERT INTO "room" VALUES(6,'garden','Garden','Front garden');
CREATE TABLE "room_attribute" (
  "id" integer PRIMARY KEY,
  "name" varchar(30) default NULL,
  "value" varchar(200) default NULL
);
INSERT INTO "room_attribute" VALUES(1,'zone','Upstairs');
INSERT INTO "room_attribute" VALUES(2,'zone','Downstairs');
INSERT INTO "room_attribute" VALUES(3,'zone','Outside');
INSERT INTO "room_attribute" VALUES(4,'rowspan','2');
CREATE TABLE "room_attribute_link" (
  "id" integer PRIMARY KEY,
  "room" int(11) default NULL,
  "room_attribute" int(11) default NULL
);
INSERT INTO "room_attribute_link" VALUES(7,4,1);
INSERT INTO "room_attribute_link" VALUES(8,2,1);
INSERT INTO "room_attribute_link" VALUES(9,3,2);
INSERT INTO "room_attribute_link" VALUES(10,6,3);
INSERT INTO "room_attribute_link" VALUES(11,5,2);
INSERT INTO "room_attribute_link" VALUES(12,1,2);
INSERT INTO "room_attribute_link" VALUES(13,1,4);
CREATE TABLE "room_device_link" (
  "id" integer PRIMARY KEY,
  "room" int(11) default NULL,
  "device" int(11) default NULL
);
INSERT INTO "room_device_link" VALUES(1,2,1);
INSERT INTO "room_device_link" VALUES(2,4,2);
INSERT INTO "room_device_link" VALUES(3,5,3);
INSERT INTO "room_device_link" VALUES(4,2,4);
INSERT INTO "room_device_link" VALUES(5,1,5);
INSERT INTO "room_device_link" VALUES(6,5,6);
INSERT INTO "room_device_link" VALUES(7,3,7);
INSERT INTO "room_device_link" VALUES(8,6,8);
INSERT INTO "room_device_link" VALUES(9,4,9);
INSERT INTO "room_device_link" VALUES(10,2,10);
INSERT INTO "room_device_link" VALUES(11,2,11);
INSERT INTO "room_device_link" VALUES(12,1,13);
INSERT INTO "room_device_link" VALUES(13,5,12);
INSERT INTO "room_device_link" VALUES(14,4,14);
INSERT INTO "room_device_link" VALUES(15,4,15);
INSERT INTO "room_device_link" VALUES(16,2,16);
INSERT INTO "room_device_link" VALUES(17,2,17);
INSERT INTO "room_device_link" VALUES(18,5,18);
INSERT INTO "room_device_link" VALUES(19,3,19);
INSERT INTO "room_device_link" VALUES(20,1,20);
INSERT INTO "room_device_link" VALUES(21,5,21);
INSERT INTO "room_device_link" VALUES(22,3,22);
INSERT INTO "room_device_link" VALUES(23,1,23);
INSERT INTO "room_device_link" VALUES(24,1,25);
INSERT INTO "room_device_link" VALUES(25,1,24);
INSERT INTO "room_device_link" VALUES(26,1,26);
CREATE TABLE "rule" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "trig" text,
  "type" varchar(30) default NULL,
  "action" text,
  "active" tinyint(1) default NULL,
  "mtime" int(11) default NULL,
  "ftime" int(11) default NULL
);
INSERT INTO "rule" VALUES(1,'cuckoo','recurrence freq=hourly minutes="[0,15,30,45]"','at','xpl -c osd.basic command=clear text="It is [% zenah.datetime.strftime("%H:%M") %]" delay=10
',1,1186321944,1186778702);
INSERT INTO "rule" VALUES(2,'x10lamp_trigger','message_type="xpl-trig" class="x10.basic" command=(on|off|bright|dim)','xpl','[% SET lamp_name = zenah.map.lookup(''x10lamp_trigger'',xpl.device) %]
[% IF lamp_name %]
  [% SET unit = zenah.device.by_name(lamp_name).attribute(''unit'') %]
  [% IF unit %]
    xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=[% xpl.command %][% IF xpl.command == ''bright'' or xpl.command == ''dim'' %] level=[% xpl.level %][% END %]
  [% END %]
[% END %]',1,1186334308,2007);
INSERT INTO "rule" VALUES(3,'x10app_trigger','message_type="xpl-trig" class="x10.basic" command=(on|off)','xpl','[% SET app_name = zenah.map.lookup(''x10app_trigger'',xpl.device) %]
[% IF app_name %]
  [% SET unit = zenah.device.by_name(app_name).attribute(''unit'') %]
  [% IF unit %]
    xpl -m xpl-cmnd -c x10.basic device="[% unit %]" command=[% xpl.command %]
  [% END %]
[% END %]
',1,1186334297,2007);
INSERT INTO "rule" VALUES(4,'dusk','sunset minutes="-20"','at','scene all_windows state=close
',1,1186145585,1186773464);
INSERT INTO "rule" VALUES(5,'all_windows',NULL,'scene','# map ''on'' => ''open'' and ''off'' to ''close''
[% SET action = state == ''on'' ? ''open'' : (state == ''off'' ? ''close'' : state) %]
[% FOREACH dev = zenah.device.by_type_list("Curtain") %]
  [% dev.action("$action") %]
[% END %]
[% FOREACH dev = zenah.device.by_type_list("Blind") %]
  # Power supply can only serve 3 blinds at once so we pause a little
  [% IF loop.count AND ( loop.count % 3 ) == 0 %]
    sleep 30
  [% END %]
  [% dev.action("$action") %]
  # could be written:
  # device [% dev.name %] [% action %]
[% END %]
',1,1186342242,1186773465);
INSERT INTO "rule" VALUES(6,'kettle',NULL,'scene','[% zenah.device.by_name(''kettle'').action("$state") %]
[% IF state == ''on'' %]
enable kettle_warn
[% ELSE %]
disable kettle_warn
[% END %]
',1,1186150221,1186322063);
INSERT INTO "rule" VALUES(7,'scene_trigger','message_type="xpl-trig" class="x10.basic" command=(on|off)','xpl','[% SET scene_name = zenah.map.lookup(''scene_trigger'',xpl.device) %]
[% IF scene_name %]
scene [% scene_name %] state=[% xpl.command %]
[% END %]
',1,1186334285,2007);
INSERT INTO "rule" VALUES(8,'kettle_warn','30','at','xpl -c osd.basic command=clear row=3 text="Kettle is on" delay=5
',0,1186322063,NULL);
INSERT INTO "rule" VALUES(9,'cleaner_prep','recurrence freq=weekly hours=11 minutes=30 days=th','at','scene all_windows state=on
# device washing_machine on',1,1186340154,NULL);
INSERT INTO "rule" VALUES(10,'motion_state','message_type="xpl-trig" class="x10.basic" command=on','xpl','[% SET dev = zenah.device.by_attr(''unit'', xpl.device) %]
[% IF dev and dev.type == ''X10Motion'' %]
  [% SET t = zenah.time %]
  [% FOREACH room = dev.rooms %]
    [% CALL zenah.state.set(''motion'', room.name, ''occupied'') %]
    scene motion_trigger state=on room="[% room.name %]"
  [% END %]
[% END %]
',1,1186218390,1186322734);
INSERT INTO "rule" VALUES(11,'light_state','message_type="xpl-trig" class="x10.basic" command=(on|off)','xpl','[% SET dev = zenah.device.by_attr(''unit'', xpl.device) %]
[% IF dev and dev.type == ''X10Light'' %]
  [% SET t = zenah.time %]
  [% FOREACH room = dev.rooms %]
    [% SET var = room.name %]
    [% SET value = xpl.command == ''on'' ? ''dark'' : ''light'' %]
    [% CALL zenah.state.set(''light'', var, value) %]
  [% END %]
[% END %]',1,1186218870,1186322734);
INSERT INTO "rule" VALUES(12,'motion_trigger',NULL,'scene','[%# trigger regardless of light state %]
[% SET lamp_name = zenah.map.lookup(''motion_trigger'',room) %]
debug [% lamp_name %] in [% room %]
[% IF lamp_name %]
  [% zenah.device.by_name(lamp_name).action("$state") %]
[% END %]

[%# trigger only if the room is dark %]
[% SET light = zenah.state.get(''light'', room) %]
[% IF light.value == ''dark'' OR state == ''off'' %]
  [% SET lamp_name = zenah.map.lookup(''motion_dark_trigger'',room) %]
  [% IF lamp_name %]
    [% zenah.device.by_name(lamp_name).action("$state") %]
  [% END %]
[% END %]
',1,1186334273,2007);
INSERT INTO "rule" VALUES(13,'motion_check','recurrence freq=minutely seconds=17','at','[% SET t = zenah.time %]
[% FOREACH room = zenah.room.all %]
  [% SET timeout = room.attribute(''motion_timeout'') %]
  [% NEXT UNLESS timeout %]
  [% SET cutoff = t - timeout %]
  [% SET motion = zenah.state.get(''motion'', room.name) %]
  [% NEXT UNLESS motion %]
  [% NEXT UNLESS motion.value == ''occupied'' %]
  [% NEXT UNLESS motion.mtime < cutoff %]
  scene motion_trigger state=off room="[% room.name %]"
  [% CALL zenah.state.set(''motion'', room.name, ''empty'') %]
[% END %]

',1,1186218660,1186779504);
INSERT INTO "rule" VALUES(14,'sensor_history','message_type="(xpl-trig|xpl-stat)" class="sensor.basic"','xpl','[% SET t = zenah.time %]

[%# Add to state table for quick lookup of latest value %]
[% CALL zenah.state.set(xpl.type, xpl.device, xpl.current) %]

',1,1186340259,1186340414);
CREATE TABLE "state" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "type" varchar(20) default NULL,
  "value" varchar(200) default NULL,
  "mtime" int(11) default NULL,
  "ctime" int(11) default NULL
);
INSERT INTO "state" VALUES(1,'bath','light','light',1186322128,1186322128);
INSERT INTO "state" VALUES(2,'bed_1','light','light',1186322146,1186322146);
INSERT INTO "state" VALUES(3,'kitchen','light','light',1186322150,1186322150);
INSERT INTO "state" VALUES(4,'cloak','light','light',1186322156,1186322156);
INSERT INTO "state" VALUES(5,'lounge','light','light',1186322168,1186322168);
INSERT INTO "state" VALUES(6,'bath','motion','occupied',1186322191,1186322191);
INSERT INTO "state" VALUES(7,'bed_1','motion','occupied',1186322192,1186322192);
INSERT INTO "state" VALUES(8,'cloak','motion','occupied',1186322734,1186322193);
INSERT INTO "state" VALUES(9,'kitchen','motion','occupied',1186322194,1186322194);
INSERT INTO "state" VALUES(10,'lounge','motion','occupied',1186322195,1186322195);
INSERT INTO "state" VALUES(11,'uv138.55','uv','2',1186340338,1186340338);
INSERT INTO "state" VALUES(12,'26.6DA373000000','temp','26.7',1186340387,1186340387);
INSERT INTO "state" VALUES(13,'26.6DA373000000','humidity','55.0025',1186340414,1186340414);
CREATE TABLE "template" (
  "id" integer PRIMARY KEY,
  "type" varchar(20) default NULL,
  "name" varchar(80) default NULL,
  "text" text,
  "mtime" int(11) default NULL
);
INSERT INTO "template" VALUES(1,'content','downstairs','<table cellpadding="0" cellspacing="0" width="80%" border="1">
<tr>
  [% PROCESS room/wrapper room = "kitchen" %]
  [% PROCESS room/wrapper room = "lounge" %]
</tr>
<tr>
  [% PROCESS room/wrapper room = "cloak" %]
</tr>
</table>
',1231334426);
INSERT INTO "template" VALUES(3,'content','upstairs','<table cellpadding="0" cellspacing="0" width="80%" border="1">
<tr>
  [% PROCESS room/wrapper room = "bath" %]
  [% PROCESS room/wrapper room = "bed_1" %]
</tr>
</table>
',1231333634);
INSERT INTO "template" VALUES(4,'room','name','<div class="button"
  ><a href="[% base _ "?content=room&room=devices&room_name=" _ r.name %]"
     ><div class="roomname">[% r.string %]</div></a></div>
',1231333808);
INSERT INTO "template" VALUES(5,'room','motion','[% USE state_table = Class(''ZenAH::Model::CDBI::State'') %]
[% USE hexcol = format(''%02x%02x%02x'') %]
[% r.string %]<br/>
[% SET m = state_table.search({ type => ''motion'', name => r.name }) %]
[% IF m %]
  <table width="100%">
    <tr><td>[% m.value %]</td></tr>
    <tr><td>[% m.to_view("mtime") %]</td></tr>
    [% SET cutoff = 7200 %]
    [% SET age = now - m.mtime %]
    [% SET col = age < cutoff ? 255 * ( age / cutoff ) : 255 %]
    <tr><td bgcolor="#[% hexcol(255-col, 0, col) %]">&nbsp;</td></tr>
  </table>
[% ELSE %]
  unknown
[% END %]
',1231335373);
INSERT INTO "template" VALUES(6,'room','light','[% USE state_table = Class(''ZenAH::Model::CDBI::State'') %]
[% USE hexcol = format(''%02x%02x%02x'') %]
[% r.string %]<br/>
[% SET l = state_table.search({ type => ''light'',
                                name => r.name }) %]
[% IF l %]
  <table width="100%" height="100%">
    <tr><td>[% l.value %]</td></tr>
    <tr><td>[% l.to_view(''ctime'') %]</td></tr>
    [% IF l.value == "light" %]
      [% SET col = 255 %]
    [% ELSE %]
      [% SET cutoff = 7200 %]
      [% SET age = now - l.ctime %]
      [% SET col = 255 - ( age < cutoff ? 255 * ( age / cutoff ) : 255 ) %]
    [% END %]
    <tr><td bgcolor="#[% hexcol(col, col, col) %]" border="1">&nbsp;</td></tr>
  </table>
[% ELSE %]
  unknown
[% END %]
',1231335526);
INSERT INTO "template" VALUES(7,'content','room','<table cellpadding="0" cellspacing="0" width="80%" border="1">
<tr>
  [% PROCESS room/wrapper room = Catalyst.request.param(''room_name'') %]
</tr>
</table>
',1231333624);
INSERT INTO "template" VALUES(8,'room','devices','<table valign="top" border="0" width="100%">
<tr>
  <th valign="top">[% r.string %]</th>
</tr>
[% FOR d = r.devices %]
  [% NEXT UNLESS d.device_controls %]
  <tr>
    <td>
      [% PROCESS html/device device = d %]
    </td>
  </tr>
[% END %]
</table>
',1231333834);
INSERT INTO "template" VALUES(9,'html','device','<table valign="top" border="0">
<tr>
  <th halign="right">
    <div class="devicename">[% device.string %]</div>
  </th>
  [% IF device.type == "Button" %]
    [% PROCESS html/buttonset button = device %]
  [% ELSE %]
    [% FOR control = device.device_controls %]
    <td onclick="device_func([''args__[% device.name %]'',''args__[% control.name %]''],[''zenah_status'']);Effect.Pulsate(this);return false;">
      <div class="button"><a class="devicecontrol"
        href="[% base _ "action/" _ device.name _ "/" _ control.name %]"
        >[% control.string %]</a></div>
    </td>
    [% END %]
  [% END %]
</tr>
</table>
',1231330928);
INSERT INTO "template" VALUES(10,'room','lights','<table border="0" width="100%" height="100%"
       class="roomtable[% r.name %]">
<tr>
  <th valign="top">[% r.string %]</th>
</tr>
[% FOR d = r.devices %]
  [% NEXT UNLESS d.type == ''X10Lamp'' %]
  <tr>
    <td>
      [% PROCESS html/device device = d %]
    </td>
  </tr>
[% END %]
</table>
',1231333919);
INSERT INTO "template" VALUES(11,'room','windows','<table valign="top" border="0">
<tr>
  <th valign="top">[% r.string %]</th>
</tr>
[% FOR d = r.devices %]
  [% NEXT UNLESS d.type == ''Blind'' or d.type == ''Curtain'' %]
  <tr>
    <td>
      [% PROCESS html/device device = d %]
    </td>
  </tr>
[% END %]
</table>
',1231333976);
INSERT INTO "template" VALUES(13,'html','header','<!-- BEGIN header -->
<img id="logo" class="logo" height="50" width="50" alt="zenah logo"
     src="[% Catalyst.uri_for("/images") %]/zenah-50.png" />
<h1 class="title">[% template.title or site.title %]</h1>
<!-- END header -->
',1231328302);
INSERT INTO "template" VALUES(14,'html','nav','<!-- BEGIN nav -->
<div id="topnav">
[% navbutton("","Home") %]
[% variant_button("navbutton", "Lights", { "room" => "lights" }) %]
[% variant_button("navbutton", "Devices", { "room" => "devices" }) %]
[% variant_button("navbutton", "Windows", { "room" => "windows" }) %]
[% variant_button("navbutton", "Motion", { "room" => "motion" }) %]
[% variant_button("navbutton", "Light", { "room" => "light" }) %]
[% variant_button("navbutton", "Sensors", { "room" => "sensors" }) %]
[% navbutton("admin", "Admin") %]
</div>
<div id="leftnav">
[%# variant_button("navbutton", "House", { "content" => "house" }) %]
[%# variant_button("navbutton", "Upstairs", { "content" => "upstairs" }) %]
[%# variant_button("navbutton", "Downstairs", { "content" => "downstairs" }) %]
</div>
<!-- END nav -->
',1231324346);
INSERT INTO "template" VALUES(16,'html','footer','<!-- BEGIN footer -->
<div id="copyright">&copy; [% site.copyright %]</div>
<!-- END footer -->
',1231337560);
INSERT INTO "template" VALUES(17,'html','buttonset','[% FOR attribute = device.device_attributes %]
  [% NEXT UNLESS attribute.name == "button" %]
  [% SET v = attribute.value.split(":") %]
  [% SET name = v.0 %]
  [% SET desc = v.1 || name %]
  <td onclick="device_func([''args__[% device.name %]'',''args__[% name %]''],[''zenah_status'']);Effect.Pulsate(this);return false;">
    <div class="button"><a
      href="[% base _ "action/" _ device.name _ "/" _ name %]"
      ><div class="devicecontrol">[% desc %]</div></a></div>
  </td>
[% END %]
',1188675335);
INSERT INTO "template" VALUES(22,'config','main','[% # config/main
   #
   # This is the main configuration template which is processed before
   # any other page, by virtue of it being defined as a PRE_PROCESS 
   # template.  This is the place to define any extra template variables,
   # macros, load plugins, and perform any other template setup.

   IF Catalyst.debug;
     # define a debug() macro directed to Catalyst''s log
     MACRO debug(message) CALL Catalyst.log.debug(message);
   END;

   # define a data structure to hold sitewide data
   site = {
     title     => ''Zen Automated Home'',
     logo      => Catalyst.uri_for("/images/zenah-150.png"),
     copyright => ''2006, 2009 Mark Hindess'',
   };

   # load up any other configuration items 
   PROCESS config/col
         + config/macro
         + config/url;

   # set defaults for variables, etc.
   DEFAULT 
     message = '''';

-%]
',1185028812);
INSERT INTO "template" VALUES(23,'site','wrapper','[% IF template.name.match(''.(css|js|txt)'') OR template.name.match(''(png|json|text|fragment)'');
     debug("Passing page through as text: $template.name");
     content;
   ELSE;
     IF template.name.match(''dojo'');
       debug("Applying DOJO wrapper to $template.name");
       content WRAPPER site/dojo;
     ELSE;
       debug("Applying HTML wrapper to $template.name");
       content WRAPPER site/html;
     END;
   END;
-%]
',1231328601);
INSERT INTO "template" VALUES(24,'config','col','[% site.rgb = {
     black   = ''#000000''
     white   = ''#ffffff''
     grey1   = ''#484848''
     grey2   = ''#cccccc''
     grey3   = ''#efefef''
     red     = ''#CC4444''
     green   = ''#66AA66''
     blue    = ''#89b8df''
     orange  = ''#f08900''
     grey2_t = ''#cceeee''
     purple  = ''#551a8b''
     house   = ''#12171c''
     roof    = ''#4ca7ab''
     door    = ''#aa1914''
   };

   site.col = {
      page    = site.rgb.white
      text    = site.rgb.grey1
      head    = site.rgb.grey3
      line    = site.rgb.door
      message = site.rgb.green
      error   = site.rgb.red
      nav = {
        background = site.rgb.grey3
        foreground = site.rgb.white
        border     = site.rgb.house
        button = {
          cur = {
            background = site.rgb.house
            foreground = site.rgb.white
            border     = site.rgb.house
            hover      = site.rgb.grey2_t
          }
          background = site.rgb.roof
          foreground = site.rgb.black
          border     = site.rgb.grey3
          hover      = site.rgb.grey2_t
        }
      }
      crudbutton = {
        background = site.rgb.roof
        foreground = site.rgb.black
        border     = site.rgb.grey1
        hover      = site.rgb.grey2_t
      }
      filterbutton = {
        background = site.rgb.roof
        foreground = site.rgb.black
        border     = site.rgb.grey1
        hover      = site.rgb.grey2_t
      }
      pagebutton = {
        background = site.rgb.grey2
        foreground = site.rgb.black
        border     = site.rgb.grey1
        hover      = site.rgb.grey2_t
      }
      list = {
        row0 = site.rgb.grey3
        row1 = site.rgb.white
      }
   };
%]
',1185008838);
INSERT INTO "template" VALUES(25,'config','macro','[% USE String %]
[% MACRO variant_button(type, name, variant) BLOCK %]
  [% SET var = Catalyst.request.param(variant.keys.0) %]
  [% SET cc = variant.values.0 == var ? "-current" : "" %]
 <span class="[% type %][% cc %]">[% variant_url(Catalyst, name, variant) %]</span>
[% END %]

[% MACRO navbutton(type, name) BLOCK %]
  [% SET room = Catalyst.request.param(''room'') %]
  [% SET cc = type == room or ( room == "" and type == "home" ) ?
         "-current" : "" %]
  <span class="navbutton[% cc %]"><a
    href="[% Catalyst.uri_for("/", type) %]"
    >[% IF name %][% name %][% ELSE %][% type FILTER ucfirst %][% END %]</a></span>
[% END %]

[% MACRO filternav(filters,current) BLOCK %]
<p class="filternav" id="filternav">
Filter:
[% FOREACH filter = filters %]
  [% IF filter == current %]
    <span class="filterbutton-current">[% filter %]</span>
  [% ELSE %]
    <span class="filterbutton"><a
      href="[% Catalyst.uri_for(".", { ''filter'' => filter }) %]"
       >[% filter %]</a></span>
  [% END %]
[% END %]
</p>
[% END %]
',1188675330);
INSERT INTO "template" VALUES(26,'config','url','[% base = Catalyst.req.base;

   site.url = {
     base    = base
     home    = "${base}welcome"
     message = "${base}message"
   }
-%]
',1185008875);
INSERT INTO "template" VALUES(27,'site','html','<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <title>[% template.title or site.title %]</title>
  <style type="text/css">
[% PROCESS site/style.css %]
  </style>
[% IF meta_refresh %]
  <meta http-equiv="refresh" content="[% meta_refresh %]">
[% END %]
  <script src="http://www.google.com/jsapi"></script>
  <script type="text/javascript">
    google.load("prototype", "1.6");
    google.load("scriptaculous", "1.8.1");
  </script>
  <script src="[% Catalyst.uri_for("/js") %]/excanvas/excanvas.js"
          type="text/javascript"></script>
  <script src="[% Catalyst.uri_for("/js") %]/plotr/plotr.js"
          type="text/javascript"></script>
  <script src="[% Catalyst.uri_for("/js") %]/ajax.js"
          type="text/javascript"></script>
 </head>
 <body>
[% content %]
 </body>
</html>
',1186318302);
INSERT INTO "template" VALUES(28,'site','style.css','html {
    height: 100%;
}

body { 
    background-color: [% site.col.page %];
    color: [% site.col.text %];
    margin: 0px;
    padding: 0px;
    height: 100%;
}

#logo {
    float: right;
}

#header {
    background-color: [% site.col.head %];
}

#footer {
    background-color: [% site.col.head %];
    text-align: center;
    border-top: 1px solid [% site.col.line %];
    position: absolute;
    bottom: 0;
    left: 0px;
    width: 100%;
    padding: 4px;
}

#content {
    padding: 10px;
}

h1.title {
    padding: 0.1em;
    margin: 0px;
    font: Ariel;
    color: #12171c;
}

.message {
    color: [% site.col.message %];
}

.error {
    color: [% site.col.error %];
}

#nav {
    padding: 2px 0px;
    border-bottom: 5px solid [% site.col.nav.border %];
    background-color: [% site.col.nav.background %];
}

.navbutton-current {
    border-style: hidden;
    padding: 3px 3px 2px 3px;
    border-color: [% site.col.nav.button.cur.border %];
    background: [% site.col.nav.button.cur.background %];
}

.navbutton {
    border-bottom: 1px solid [% site.col.nav.button.border %];
    padding: 3px 3px 1px 3px;
    background: [% site.col.nav.button.background %];
}

.navbutton-current A {
    color: [% site.col.nav.button.cur.foreground %];
    font-weight: bold;
    text-decoration: none;
} 

.navbutton-current A:hover {
    color: [% site.col.nav.button.cur.foreground %];
    font-weight: bold;
    text-decoration: none;
} 

.navbutton-current img {
    border-style: hidden;
}

.navbutton A {
    color: [% site.col.nav.button.foreground %];
    font-weight: bold;
    text-decoration: none;
} 

.navbutton A:hover {
    background: [% site.col.nav.button.hover %];
} 

.navbutton img {
    border-style: hidden;
}

div.button {
}

div.button A {
  color: #000000;
  font-weight: bold;
  text-decoration: none;
} 

div.roomname {
  border-width: 2px 2px 2px 2px;
  padding: 1px 1px 1px 1px;
  border-style: outset outset outset outset;
  border-color: teal;
  background-color: #99aaaa;
}

div.devicename {
  border-width: 2px 2px 2px 2px;
  padding: 1px 1px 1px 1px;
  border-style: outset outset outset outset;
  border-color: teal;
  background-color: #ccffff;
}

a.devicecontrol {
  border-width: 2px 2px 2px 2px;
  padding: 1px 1px 1px 1px;
  border-style: outset outset outset outset;
  border-color: teal;
  background: #99cccc;
}

div.status {
  colour: white;
  padding: 2px 2px 2px 2px;
  border-style: outset;
  border-color: #cc0000;
  background-color: #cc0000;
  width: 450px;
  float: top;
  float: left;
  font-weight: bold;
}

content {
  width: 100%;
  height: 380;
  padding: 0px 0px 0px 0px;
  background: white;
  margin-top: 15px;
}
',1231328177);
INSERT INTO "template" VALUES(30,'html','layout','<div id="header">[% PROCESS html/header %]</div>

<div id="nav">[% PROCESS html/nav %]</div>

<div class="status" name="zenah_status" id="zenah_status"
  >[% status ? status : '' '' %]</div>
<br/>
<p></p>
<br/>
<div id="content">
[% PROCESS content/default %]
</div>

<div id="footer">[% PROCESS html/footer %]</div>
',1185370939);
INSERT INTO "template" VALUES(32,'content','house','[% PROCESS content/upstairs %]
<br />
[% PROCESS content/downstairs %]
<br />
[% PROCESS content/garden %]

',1185623448);
INSERT INTO "template" VALUES(33,'content','default','[% SET t_content = ''content/'' _ (Catalyst.request.param(''content'') || ''house'') %]
[% PROCESS $t_content %]',1185032774);
INSERT INTO "template" VALUES(34,'room','wrapper','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET r = table_class.search({ name => room }) %]
[% IF r %]
  <td valign="top"
      rowspan="[% r.attribute(''rowspan'') || 1 %]"
      colspan="[% r.attribute(''colspan'') || 1 %]">
    [% SET t_room = ''room/'' _ (Catalyst.request.param(''room'') || ''name'') %]
    [% PROCESS $t_room %]
  </td>
[% ELSE %]
  Invalid room ''[% room %]''
[% END %]
',1231335750);
INSERT INTO "template" VALUES(35,'content','garden','<table cellpadding="0" cellspacing="0" width="80%" border="1">
<tr>
  [% PROCESS room/wrapper room = "garden" %]
</tr>
</table>
',1231333612);
INSERT INTO "template" VALUES(36,'site','error','[% META title = ''Catalyst/TT Error'' %]
<p>
  An error has occurred.  We''re terribly sorry about that, but it''s 
  one of those things that happens from time to time.  Let''s just 
  hope the developers test everything properly before release...
</p>
<p>
  Here''s the error message, on the off-chance that it means something
  to you: <span class="error">[% error %]</span>
</p>
',1231325949);
INSERT INTO "template" VALUES(37,'site','dojo','<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <title>[% template.title or site.title %]</title>
  <script src="http://www.google.com/jsapi"></script>
  <script type="text/javascript">
    var djConfig = {
       isDebug:true, parseOnLoad:true
    };
    google.load("dojo", "1.2.3");
  </script>
  <script type="text/javascript">
    dojo.require("dijit.layout.BorderContainer");
    dojo.require("dijit.layout.ContentPane");
    dojo.require("dijit.layout.TabContainer");
    dojo.require("dijit.form.Button");
    dojo.require("dojo.parser");

    function button_action(device, action) {
      dojo.xhrGet( {
        url: "[% Catalyst.uri_for("ajax") %]?args="+device+"&args="+action,
        handleAs: "text",
        timeout: 3000,
        load: function(response, ioArgs) {
          dojo.byId("status").innerHTML = response;
          return response;
        },
        error: function(response, ioArgs) {
          dojo.byId("status").innerHTML = "HTTP error: " + ioArgs.xhr.status;
          return response;
        },
      });
    }
  </script>

  <style type="text/css">
    @import "http://ajax.googleapis.com/ajax/libs/dojo/1.2.3/dojo/resources/dojo.css";
    @import "http://ajax.googleapis.com/ajax/libs/dojo/1.2.3/dijit/themes/tundra/tundra.css";

    html, body {
      width: 100%;	/* make the body expand to fill the visible window */
      height: 100%;
      padding: 0 0 0 0;
      margin: 0 0 0 0;
    }

    #logo {
    float: right;
    }

    h1.title {
      padding: 0.1em;
      margin: 0px;
      font: Ariel;
      font-weight: bold;
      color: #12171c;
    }
  </style>
[% IF meta_refresh %]
  <meta http-equiv="refresh" content="[% meta_refresh %]">
[% END %]
 </head>
 <body class="tundra">
[% content %]
 </body>
</html>',1231325080);
INSERT INTO "template" VALUES(38,'dojo','device','<b>[% device.string %]:</b>
[% FOR control = device.device_controls %]
  <button dojoType="dijit.form.Button"
    onclick="button_action(''[% device.name %]'',''[% control.name %]'');">
    [% control.string %]
  </button>
[% END %]
<br/>',1188649372);
INSERT INTO "template" VALUES(39,'dojo','layout','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
<div id="outer" dojotype="dijit.layout.BorderContainer"
     style="width: 100%; height: 100%;">
  <div id="topBar" dojotype="dijit.layout.ContentPane"
       region="top" layoutalign="top"
       style="background-color: [% site.col.head %]; border-bottom: 3px solid [% site.col.nav.border %];">
    <img id="logo" class="logo" height="40" width="40"
         src="[% Catalyst.uri_for("/images") %]/zenah-50.png" />
    <h1 class="title">[% template.title or site.title %]</h1>
    <div id="status">&nbsp;</div>
  </div>
  <div id="bottomBar" dojotype="dijit.layout.ContentPane" region="bottom"
       layoutalign="bottom"
       style="background-color: [% site.col.head %]; text-align: center;">
    <div id="copyright">&copy; [% site.copyright %]</div>
  </div>

    <div id="mainTabContainer" dojotype="dijit.layout.TabContainer"
         region="center" layoutAlign="client">
      [% FOR zone = [''Downstairs'', ''Upstairs'', ''Outside''] %]
        <div id="[% zone %]TabContainer"
             dojotype="dijit.layout.TabContainer" title="[% zone %]">
          [% FOR r = table_class.by_attribute(''zone'', zone) %]
            <div id="[% r.name %]_tab" dojoType="dijit.layout.ContentPane"
                 title="[% r.string %]"
                 href="[% Catalyst.uri_for("/dojofragment/room") _ "?room=" _ r.id %]">
            </div>
          [% END %]
        </div>
      [% END %]
    </div>
    <div id="fill"></div>
</div>
',1231337530);
INSERT INTO "template" VALUES(40,'dojofragment','room','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET room = table_class.retrieve(Catalyst.request.param(''room'')) %]
[% FOR d = room.devices %]
  [% NEXT IF d.type == ''Sensor'' %]
  [% NEXT UNLESS d.device_controls %]
  [% PROCESS dojo/device device = d %]
[% END %]
<b>Sensors:</b>
[% FOR d = room.devices %]
  [% NEXT UNLESS d.type == ''Sensor'' %]
  [% NEXT UNLESS d.device_controls %]
  [% PROCESS dojo/sensor device = d %]
[% END %]
',1231323494);
INSERT INTO "template" VALUES(41,'text','completions','[% USE table_class = Class(''ZenAH::Model::CDBI::Device'') -%]
[% SET q = Catalyst.request.param(''query'') -%]
[% FOREACH d = table_class.retrieve_all( order_by => ''name'' ) -%]
[% FOREACH c = d.device_controls -%]
[% SET s = d.name _ "/" _ c.name -%]
[% IF s.substr(0, q.length) == q -%]
[% s %]
[% END -%]
[% END -%]
[% END -%] 
',1223981035);
INSERT INTO "template" VALUES(42,'dojo','sensor','[% FOR control = device.device_controls %]
  <button dojoType="dijit.form.Button"
    onclick="button_action(''[% device.name %]'',''[% control.name %]'');">
    [% device.string _ ": " _ control.string %]
  </button>
[% END %]
',1231323391);
INSERT INTO "template" VALUES(43,'dojofragment','zone','[% USE table_class = Class(''ZenAH::Model::CDBI::Room'') %]
[% SET zone = Catalyst.request.param(''zone'') %]
[% FOR r = table_class.by_attribute(''zone'', zone) %]
  <div id="[% r.name %]_tab" dojoType="dijit.layout.ContentPane"
    title="[% r.string %]"
    href="[% Catalyst.uri_for("/dojofragment/room") _ "?room=" _ r.id %]"
    ></div> 
[% END %]
',1231323529);
INSERT INTO "template" VALUES(44,'room','sensors','<table valign="top" border="0">
<tr>
  <th valign="top">[% r.string %]</th>
</tr>
[% FOR d = r.devices %]
  [% NEXT UNLESS d.type == ''Sensor'' %]
  <tr>
    <td>
      [% PROCESS html/sensor device = d %]
    </td>
  </tr>
[% END %]
</table>
',1231333960);
INSERT INTO "template" VALUES(45,'html','sensor','[% USE table_class = Class(''ZenAH::Model::CDBI::State'') %]
[% IF device.attribute("uid") %]
  [% SET s = table_class.search({ name => device.name }) %]
[% ELSE %]
  [% SET s = [] %]
[% END %]
<table valign="top" border="0">
<tr>
  <th halign="right" rowspan="3">
    <div class="devicename">[% device.string %]</div>
  </th>
  [% IF s %]
    [% FOREACH sensor = s %]
      <th>
        [% sensor.type %]
      </th>
    [% END %]
    </tr>
    <tr>
     [% FOREACH sensor = s %]
      <td>
        [% sensor.value %]
        <small> @
          [% sensor.to_view(''mtime'') %]
        </small>
      </td>
    [% END %]
  [% ELSE %]
    <td rowspan="3">no results</td>
  [% END %]
</tr>
</table>
',1231335632);
CREATE TABLE "timestamp" (
  "id" integer PRIMARY KEY,
  "name" varchar(80) default NULL,
  "time" int(11) default NULL
);
CREATE TABLE "device_control" (
  "id" integer PRIMARY KEY,
  "type" varchar(20) default NULL,
  "name" varchar(50) default NULL,
  "definition" text,
  "string" varchar(80) default NULL,
  "description" text
);
INSERT INTO "device_control" VALUES(1,'x10','on','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=on
[% ELSE %]
  error ''invalid device''
[% END %]
','On',NULL);
INSERT INTO "device_control" VALUES(2,'x10','off','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=off
[% ELSE %]
  error ''invalid device''
[% END %]
','Off',NULL);
INSERT INTO "device_control" VALUES(3,'x10','bright','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=bright level=5
[% ELSE %]
  error ''invalid device''
[% END %]
','Bright',NULL);
INSERT INTO "device_control" VALUES(4,'x10','dim','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=dim level=5
[% ELSE %]
  error ''invalid device''
[% END %]
','Dim',NULL);
INSERT INTO "device_control" VALUES(5,'curtain','open','[% SET relay = device.attribute(''open_relay'') %]
[% IF relay %]
  xpl -c control.basic device=[% relay %] type=output current=pulse
[% ELSE %]
  error ''invalid device''
[% END %]
','Open',NULL);
INSERT INTO "device_control" VALUES(6,'curtain','close','[% SET relay = device.attribute(''close_relay'') %]
[% IF relay %]
  xpl -c control.basic device=[% relay %] type=output current=pulse
[% ELSE %]
  error ''invalid device''
[% END %]
','Close',NULL);
INSERT INTO "device_control" VALUES(14,'x10','on-override','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=on
[% ELSE %]
  error ''invalid device''
[% END %]
','Force On',NULL);
INSERT INTO "device_control" VALUES(16,'x10','full-fast','[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  xpl -m xpl-cmnd -c x10.basic device=[% unit %] command=extended data1=49 data2=63
[% ELSE %]
  error ''invalid device''
[% END %]','FullFast',NULL);
INSERT INTO "device_control" VALUES(17,'x10','flash','[% USE String %]
[% SET unit = device.attribute(''unit'') %]
[% IF unit %]
  [% FOREACH count = [ 1, 2, 3, 4, 5 ] %]
    xpl -m xpl-cmnd -c x10.basic house=[% unit.substr(0,1) %] command=all_lights_on
    sleep 1
    xpl -m xpl-cmnd -c x10.basic house=[% unit.substr(0,1) %] command=all_lights_off
  [% END %]
[% ELSE %]
  error ''invalid device''
[% END %]','Flash','Flash light (and all others on same housecode)
');
INSERT INTO "device_control" VALUES(18,'blind','close','[% SET relay = device.attribute(''close_relay'') %]
[% IF relay %]
  xpl -c control.basic device=[% relay %] type=output current=pulse
[% ELSE %]
  error ''invalid device''
[% END %]
','Close',NULL);
INSERT INTO "device_control" VALUES(19,'blind','open','[% SET relay = device.attribute(''open_relay'') %]
[% IF relay %]
  xpl -c control.basic device=[% relay %] type=output current=pulse
[% ELSE %]
  error ''invalid device''
[% END %]
','Open',NULL);
COMMIT;
