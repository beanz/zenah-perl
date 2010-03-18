package ZenAH::DBIC::DeviceAttributeLink;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('device_attribute_link');
__PACKAGE__->add_columns(qw/id device device_attribute/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('device' => 'ZenAH::DBIC::Device');
__PACKAGE__->belongs_to('device_attribute' => 'ZenAH::DBIC::DeviceAttribute');

1;
