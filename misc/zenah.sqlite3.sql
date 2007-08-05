CREATE TABLE device (
  id integer primary key,
  name varchar(80),
  string varchar(80),
  description text,
  type varchar(80)
);
CREATE TABLE device_attribute (
  id integer primary key,
  name varchar(30),
  value varchar(200)
);
CREATE TABLE device_attribute_link (
  id integer primary key,
  device int(11),
  device_attribute int(11)
);
CREATE TABLE device_control (
  id integer primary key,
  name varchar(50),
  description text,
  definition text,
  string varchar(80)
);
CREATE TABLE device_control_link (
  id integer primary key,
  device int(11),
  device_control int(11)
);
CREATE TABLE list (
  id integer primary key,
  name varchar(80),
  liststate int(11)
);
CREATE TABLE listitem (
  id integer primary key,
  name text
);
CREATE TABLE listitemlink (
  id integer primary key,
  list int(11),
  listitem int(11)
);
CREATE TABLE liststate (
  id integer primary key,
  name varchar(20)
);
CREATE TABLE map (
  id integer primary key,
  type varchar(50),
  name varchar(80),
  value varchar(255)
);
CREATE TABLE phone_hist (
  id integer primary key,
  num varchar(30),
  ctime int(11)
);
CREATE TABLE room (
  id integer primary key,
  name varchar(80),
  string varchar(80),
  description text
);
CREATE TABLE room_attribute (
  id integer primary key,
  name varchar(30),
  value varchar(200)
);
CREATE TABLE room_attribute_link (
  id integer primary key,
  room int(11),
  room_attribute int(11)
);
CREATE TABLE room_device_link (
  id integer primary key,
  room int(11),
  device int(11)
);
CREATE TABLE rule (
  id integer primary key,
  name varchar(80),
  trig text,
  trig_type varchar(30),
  action text,
  active tinyint(1),
  mtime int(11),
  ftime int(11)
);
CREATE TABLE state (
  id integer primary key,
  name varchar(80),
  type varchar(20),
  value varchar(200),
  mtime int(11),
  ctime int(11)
);
CREATE TABLE template (
  id integer primary key,
  name varchar(80),
  text text,
  mtime int(11));
CREATE TABLE timestamp (
  id integer primary key,
  name varchar(80),
  time int(11)
);
