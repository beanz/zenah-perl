package ZenAH::DBIC::RoomAttributeLink;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('room_attribute_link');
__PACKAGE__->add_columns(qw/id room room_attribute/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('room' => 'ZenAH::DBIC::Room');
__PACKAGE__->belongs_to('room_attribute' => 'ZenAH::DBIC::RoomAttribute');

1;
