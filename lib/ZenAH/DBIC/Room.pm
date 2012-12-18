package ZenAH::DBIC::Room;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('room');
__PACKAGE__->add_columns(qw/id name string description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('room_attribute_links' =>
                        'ZenAH::DBIC::RoomAttributeLink',
                      'room');
__PACKAGE__->many_to_many('attributes' => 'room_attribute_links',
                          'room_attribute');

__PACKAGE__->has_many('room_device_links' => 'ZenAH::DBIC::RoomDeviceLink',
                      'room');
__PACKAGE__->many_to_many('devices' => 'room_device_links', 'device');

1;
