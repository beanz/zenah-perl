--
-- Table structure for table `device`
--

CREATE TABLE device (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  `string` varchar(80) default NULL,
  description text,
  `type` varchar(80) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `device_attribute`
--

CREATE TABLE device_attribute (
  id int(11) NOT NULL auto_increment,
  `name` varchar(30) default NULL,
  `value` varchar(200) default NULL,
  PRIMARY KEY  (id),
  KEY `name` (`name`),
  KEY `value` (`value`)
);

--
-- Table structure for table `device_attribute_link`
--

CREATE TABLE device_attribute_link (
  id int(11) NOT NULL auto_increment,
  device int(11) default NULL,
  device_attribute int(11) default NULL,
  PRIMARY KEY  (id),
  KEY device (device),
  KEY device_attribute (device_attribute)
);

--
-- Table structure for table `device_control`
--

CREATE TABLE device_control (
  id int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `type` varchar(20) default NULL,
  definition text,
  `string` varchar(80) default NULL,
  description text,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `device_control_link`
--

CREATE TABLE device_control_link (
  id int(11) NOT NULL auto_increment,
  device int(11) default NULL,
  device_control int(11) default NULL,
  PRIMARY KEY  (id),
  KEY device (device),
  KEY device_control (device_control)
);

--
-- Table structure for table `list`
--

CREATE TABLE list (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  liststate int(11) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `listitem`
--

CREATE TABLE listitem (
  id int(11) NOT NULL auto_increment,
  `name` text,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `listitemlink`
--

CREATE TABLE listitemlink (
  id int(11) NOT NULL auto_increment,
  list int(11) default NULL,
  listitem int(11) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `liststate`
--

CREATE TABLE liststate (
  id int(11) NOT NULL auto_increment,
  `name` varchar(20) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `map`
--

CREATE TABLE map (
  id int(11) NOT NULL auto_increment,
  `type` varchar(50) default NULL,
  `name` varchar(80) default NULL,
  `value` varchar(255) default NULL,
  PRIMARY KEY  (id),
  KEY `type` (`type`,`name`)
);

--
-- Table structure for table `phone_hist`
--

CREATE TABLE phone_hist (
  id int(11) NOT NULL auto_increment,
  num varchar(30) default NULL,
  ctime int(11) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `room`
--

CREATE TABLE room (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  `string` varchar(80) default NULL,
  description text,
  PRIMARY KEY  (id),
  KEY `name` (`name`)
);

--
-- Table structure for table `room_attribute`
--

CREATE TABLE room_attribute (
  id int(11) NOT NULL auto_increment,
  `name` varchar(30) default NULL,
  `value` varchar(200) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `room_attribute_link`
--

CREATE TABLE room_attribute_link (
  id int(11) NOT NULL auto_increment,
  room int(11) default NULL,
  room_attribute int(11) default NULL,
  PRIMARY KEY  (id)
);

--
-- Table structure for table `room_device_link`
--

CREATE TABLE room_device_link (
  id int(11) NOT NULL auto_increment,
  room int(11) default NULL,
  device int(11) default NULL,
  PRIMARY KEY  (id),
  KEY room (room),
  KEY device (device)
);

--
-- Table structure for table `rule`
--

CREATE TABLE rule (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  trig text,
  type varchar(30) default NULL,
  `action` text,
  active tinyint(1) default NULL,
  mtime int(11) default NULL,
  ftime int(11) default NULL,
  PRIMARY KEY  (id),
  KEY `name` (`name`)
);

--
-- Table structure for table `state`
--

CREATE TABLE state (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  `type` varchar(20) default NULL,
  `value` varchar(200) default NULL,
  mtime int(11) default NULL,
  ctime int(11) default NULL,
  PRIMARY KEY  (id),
  KEY `name` (`name`),
  KEY `type` (`type`)
);

--
-- Table structure for table `template`
--

CREATE TABLE template (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  `type` varchar(20) default NULL,
  `text` text,
  mtime int(11) default NULL,
  PRIMARY KEY  (id),
  KEY `name` (`name`),
  KEY `type` (`type`)
);

--
-- Table structure for table `timestamp`
--

CREATE TABLE `timestamp` (
  id int(11) NOT NULL auto_increment,
  `name` varchar(80) default NULL,
  `time` int(11) default NULL,
  PRIMARY KEY  (id)
);
