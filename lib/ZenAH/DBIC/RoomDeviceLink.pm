package ZenAH::DBIC::RoomDeviceLink;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('room_device_link');
__PACKAGE__->add_columns(qw/id room device/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('room' => 'ZenAH::DBIC::Room');
__PACKAGE__->belongs_to('device' => 'ZenAH::DBIC::Device');

1;
