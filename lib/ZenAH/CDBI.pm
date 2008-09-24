package ZenAH::CDBI;

use strict;
use base 'Class::DBI';
use Class::DBI::Loader;
use Class::DBI::Loader::Relationship;
use FileHandle;
use Template;
use HTML::Entities;
use HTML::Element;
no warnings;
sub Class::DBI::insert { Class::DBI::create(@_) }
use warnings;

use DateTime::Format::Strptime;

{
  package ZenAH::CDBI::Base;
  sub to_view {
    my ($self, $field) = @_;
    $self->$field();
  }
}

my $formatter = DateTime::Format::Strptime->new(pattern=>'%Y-%m-%d %H:%M:%S');
my $time_zone = $ENV{TZ} || "Europe/London";
my %args = ();

my $config = exists $ENV{ZENAH_DBI_CONFIG} ? $ENV{ZENAH_DBI_CONFIG} :
  -f 'zenah.dbi.conf' ? 'zenah.dbi.conf' : undef;
my $fh = FileHandle->new($config) or
  die "Failed to open database configuration, $config: $!\n".
      "Try setting the environment variable ZENAH_DBI_CONFIG.";
while (<$fh>) {
  next if (/^#/ or /^\s*$/);
  chomp;
  my ($key, $val) = split /\s+[=:]\s+/, $_, 2;
  $args{$key} = $val;
}
$fh->close;

my $loader = Class::DBI::Loader->new(
    %args,
    options       => {},
    #relationships => 1,
    additional_base_classes => [qw/Class::DBI::FromForm
                                   Class::DBI::AsForm
                                   ZenAH::CDBI::Base/],
    namespace => "ZenAH::CDBI",
    left_base_classes => [qw(Class::DBI::Sweet)],
);

$loader->relationship($_)
  foreach (
           "a liststate defines lists",
           "a list has listitems on listitemlinks",
           "a device has device_attributes on device_attribute_links",
           "a device has device_controls on device_control_links",
           "a room has room_attributes on room_attribute_links",
           "a room has devices on room_device_links",
          );
ZenAH::CDBI::List->has_a(liststate => 'ZenAH::CDBI::Liststate');

ZenAH::CDBI::PhoneHist->has_a(
    ctime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

ZenAH::CDBI::State->has_a(
    ctime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

ZenAH::CDBI::State->has_a(
    mtime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

ZenAH::CDBI::Rule->has_a(
    ftime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

ZenAH::CDBI::Rule->has_a(
    mtime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

sub ZenAH::CDBI::Rule::to_view {
  my ($self, $field) = @_;
  return '' unless (defined $self->$field &&
                    $self->$field ne '');
  if ($field eq 'active') {
    $self->active ? 'enabled' : 'disabled'
  } elsif ($field eq 'action' or $field eq 'trig') {
    my $small = HTML::Element->new('small');
    my $pre = HTML::Element->new('pre');
    $pre->push_content($self->$field);
    $small->push_content($pre);
    $small->as_XML;
  } else {
    $self->$field();
  }
}


ZenAH::CDBI::Template->has_a(
    mtime => 'DateTime',
    inflate => sub {
      DateTime->from_epoch(epoch => shift,
                           formatter => $formatter,
                           time_zone => $time_zone);
    },
    deflate => 'epoch'
);

sub ZenAH::CDBI::Template::to_view {
  my ($self, $field) = @_;
  return '' unless (defined $self->$field &&
                    $self->$field ne '');
  if ($field eq 'text') {
    my $small = HTML::Element->new('small');
    my $pre = HTML::Element->new('pre');
    $pre->push_content($self->$field);
    $small->push_content($pre);
    $small->as_XML;
  } else {
    $self->$field();
  }
}

ZenAH::CDBI::Device->set_sql(types => q{
  SELECT distinct type FROM __TABLE__
});
sub ZenAH::CDBI::Device::types {
  map { $_->type } $_[0]->search_types();
}

ZenAH::CDBI::Device->set_sql(type_and_attr => q{
  SELECT device.*
  FROM device, device_attribute_link, device_attribute
  WHERE device.type = ? AND
        device_attribute_link.device = device.id AND
        device_attribute_link.device_attribute = device_attribute.id AND
        device_attribute.name = ? AND
        device_attribute.value = ?
});

sub ZenAH::CDBI::Device::controls {
  ZenAH::CDBI::Device::device_controls(@_);
}
sub ZenAH::CDBI::Device::attributes {
  ZenAH::CDBI::Device::device_attributes(@_);
}
sub ZenAH::CDBI::Device::attribute {
  my $self = shift;
  my $name = shift;
  my $attr = $self->device_attributes("device_attribute.name" => $name)->first;
  return $attr && $attr->value;
}

sub ZenAH::CDBI::Device::action {
  my $self = shift;
  my $action_name = shift;
  my $device_name = $self->name;
  my $type_name = $self->type;
  $action_name =~ s/[^-a-z0-9_\/\.]/_/ig;
  my $control =
    $self->device_controls("device_control.name" => $action_name)->first;
  my $definition;
  if ($control) {
    my $input = $control->definition;
    my $output = '';
    my $t = Template->new({POST_CHOMP => 1});
    $t->process(\$input, { device => $self }, \$output) or
      return "error bad template, $action_name, on device, $device_name\n";
    $definition = $output;
  } elsif ($type_name eq "Button") {
    $definition =
      sprintf('xpl -m xpl-trig -c remote.basic device=%s keys=%s',
              $device_name, $action_name);
  } elsif ($type_name eq "DMX") {
    $definition =
      sprintf('xpl -m xpl-cmnd -c dmx.basic base=%s type=set value=%s',
              $self.attribute('base'), $action_name);
  } else {
    return "error invalid action, $action_name, on device, $device_name\n";
  }
  return $definition;
}

ZenAH::CDBI::Map->set_sql(types => q{
  SELECT distinct type FROM __TABLE__
});
sub ZenAH::CDBI::Map::types {
  my $class = shift;
  return map { $_->type } $class->search_types();
}

ZenAH::CDBI::Rule->set_sql(triggers => q{
  SELECT distinct trig_type FROM __TABLE__
});
sub ZenAH::CDBI::Rule::triggers {
  my $class = shift;
  return map { $_->trig_type } $class->search_triggers();
}

sub ZenAH::CDBI::Rule::to_field {
  my ($self, $field, $how) = @_;
  if ($field eq 'trig' or $field eq 'action') {
    my $a = $self->Class::DBI::AsForm::to_field($field, 'textarea');
    $a->attr(cols => 80);
    $a->attr(rows => $field eq 'trig' ? 2 : 10);
    if (ref $self) { $a->push_content(encode_entities($self->$field)) }
    $a;
  } elsif ($field eq 'active') {
    my $a = HTML::Element->new('select', name => $field);
    foreach ([1 => 'Enabled'],[0 => 'Disbled'],) {
      my $opt = HTML::Element->new('option', value => $_->[0]);
      $opt->attr('selected' => 'selected')
        if ( (ref $self && $self->$field == $_->[0]) ||
             $_->[0] == 1);
      $opt->push_content($_->[1]);
      $a->push_content($opt);
    }
    $a;
  } else {
    $self->Class::DBI::AsForm::to_field($field);
  }
}

ZenAH::CDBI::State->set_sql(types => q{
  SELECT distinct type FROM __TABLE__
});
sub ZenAH::CDBI::State::types {
  my $class = shift;
  return map { $_->type } $class->search_types();
}

ZenAH::CDBI::Template->set_sql(prefixes => q{
  SELECT distinct name FROM __TABLE__ where name like '%%/%%'
});
sub ZenAH::CDBI::Template::prefixes {
  my $self = shift;
  my $sth = $self->sql_prefixes();
  $sth->execute();
  my %p = map { $_=$_->[0]; s/\/.*//; $_ => 1 } @{$sth->fetchall_arrayref};
  return keys %p;
}

sub ZenAH::CDBI::Template::to_field {
  my ($self, $field, $how) = @_;
  if ($field eq 'text') {
    my $a = $self->Class::DBI::AsForm::to_field($field, 'textarea');
    $a->attr(cols => 80);
    $a->attr(rows => 10);
    if (ref $self) { $a->push_content(encode_entities($self->$field)) }
    $a;
  } else {
    $self->Class::DBI::AsForm::to_field($field);
  }
}

ZenAH::CDBI::DeviceAttribute->set_sql(types => q{
  SELECT distinct name FROM __TABLE__
});
sub ZenAH::CDBI::DeviceAttribute::types {
  my $self = shift;
  my $sth = $self->sql_types();
  $sth->execute();
  my %p = map { $_->[0] => 1 } @{$sth->fetchall_arrayref};
  return keys %p;
}

ZenAH::CDBI::RoomAttribute->set_sql(types => q{
  SELECT distinct name FROM __TABLE__
});
sub ZenAH::CDBI::RoomAttribute::types {
  my $self = shift;
  my $sth = $self->sql_types();
  $sth->execute();
  my %p = map { $_->[0] => 1 } @{$sth->fetchall_arrayref};
  return keys %p;
}

ZenAH::CDBI::DeviceControl->set_sql(prefixes => q{
  SELECT distinct name FROM __TABLE__ where name like '%%/%%'
});
sub ZenAH::CDBI::DeviceControl::prefixes {
  my $self = shift;
  my $sth = $self->sql_prefixes();
  $sth->execute();
  my %p = map { $_=$_->[0]; s/\/.*//; $_ => 1 } @{$sth->fetchall_arrayref};
  return keys %p;
}

sub ZenAH::CDBI::DeviceControl::to_field {
  my ($self, $field, $how) = @_;
  if ($field eq 'definition') {
    my $a = $self->Class::DBI::AsForm::to_field($field, 'textarea');
    $a->attr(cols => 80);
    $a->attr(rows => 4);
    if (ref $self) { $a->push_content($self->$field) }
    $a;
  } else {
    $self->Class::DBI::AsForm::to_field($field);
  }
}

sub ZenAH::CDBI::Room::attributes {
  ZenAH::CDBI::Room::room_attributes(@_);
}
sub ZenAH::CDBI::Room::attribute {
  my $self = shift;
  my $name = shift;
  my $attr = $self->room_attributes("room_attribute.name" => $name)->first;
  return $attr && $attr->value;
}

sub which_mtime {
  exists $ENV{HARNESS_ACTIVE} ? 'fakemtime' : 'mtime';
}

sub set_mtime {
  if ($_[0]->is_changed()) {
    $_[0]->_attribute_set(which_mtime() => time);
  }
}

sub set_mtime_sometimes {
  my @changed = $_[0]->is_changed();
  my $ftime = scalar @changed ==1 && $changed[0] eq "ftime";
  if (@changed && !$ftime) {
    $_[0]->_attribute_set(which_mtime() => time);
  }
}
sub set_time {
  $_[0]->_attribute_set(which_mtime() => time) unless ($_[0]->mtime);
}
ZenAH::CDBI::Rule->add_trigger(before_create => \&set_time);
ZenAH::CDBI::Rule->add_trigger(before_update => \&set_mtime_sometimes);

ZenAH::CDBI::Template->add_trigger(before_create => \&set_time);
ZenAH::CDBI::Template->add_trigger(before_update => \&set_mtime);

sub loader {
  return $loader;
}

=head1 NAME

ZenAH::CDBI - Class::DBI Interface to the Zen Automated Home Database

=head1 SYNOPSIS

  use ZenAH::CDBI;
  foreach my $room (ZenAH::CDBI::Room->retrieve_all()) {
    print $_->name, "\n";
  }

=head1 DESCRIPTION

TODO

=head1 SEE ALSO

Project website: http://www.zenah.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>zenah@beanz.uklinux.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
