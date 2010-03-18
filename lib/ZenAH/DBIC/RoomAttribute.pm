package ZenAH::DBIC::RoomAttribute;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('room_attribute');
__PACKAGE__->add_columns(qw/id name value/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('room_attribute_links' =>
                        'ZenAH::DBIC::RoomAttributeLink',
                      'room_attribute');
__PACKAGE__->many_to_many('rooms' => 'room_attribute_links',
                          'room');

1;
