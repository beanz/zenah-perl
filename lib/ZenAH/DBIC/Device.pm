package ZenAH::DBIC::Device;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('device');
__PACKAGE__->add_columns(qw/id name string description type/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('device_attribute_links' =>
                        'ZenAH::DBIC::DeviceAttributeLink',
                      'device');
__PACKAGE__->many_to_many('attributes' => 'device_attribute_links',
                          'device_attribute');

__PACKAGE__->has_many('device_control_links' =>
                        'ZenAH::DBIC::DeviceControlLink',
                      'device');
__PACKAGE__->many_to_many('controls' => 'device_control_links',
                          'device_control');

__PACKAGE__->has_many('room_device_links' =>
                        'ZenAH::DBIC::RoomDeviceLink',
                      'device');
__PACKAGE__->many_to_many('rooms' => 'room_device_links',
                          'room');

1;
