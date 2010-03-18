package ZenAH::DBIC::Map;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('map');
__PACKAGE__->add_columns(qw/id type name value/);
__PACKAGE__->set_primary_key('id');

1;
