package ZenAH::DBIC::DeviceControlLink;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('device_control_link');
__PACKAGE__->add_columns(qw/id device device_control/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('device' => 'ZenAH::DBIC::Device');
__PACKAGE__->belongs_to('device_control' => 'ZenAH::DBIC::DeviceControl');

1;
