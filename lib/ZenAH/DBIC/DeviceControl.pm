package ZenAH::DBIC::DeviceControl;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('device_control');
__PACKAGE__->add_columns(qw/id type name definition string description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('device_control_links' =>
                        'ZenAH::DBIC::DeviceControlLink',
                      'device_control');
__PACKAGE__->many_to_many('devices' => 'device_control_links',
                          'device');

1;
