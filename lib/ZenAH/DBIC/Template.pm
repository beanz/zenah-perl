package ZenAH::DBIC::Template;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('template');
__PACKAGE__->add_columns(qw/id name type text mtime/);
__PACKAGE__->set_primary_key('id');

1;
