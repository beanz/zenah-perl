package ZenAH::DBIC::DeviceAttribute;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('device_attribute');
__PACKAGE__->add_columns(qw/id name value/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('device_attribute_links' =>
                        'ZenAH::DBIC::DeviceAttributeLink',
                      'device_attribute');
__PACKAGE__->many_to_many('devices' => 'device_attribute_links',
                          'device');

1;
