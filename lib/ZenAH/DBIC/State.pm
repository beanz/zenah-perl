package ZenAH::DBIC::State;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('state');
__PACKAGE__->add_columns(qw/id name type value mtime ftime/);
__PACKAGE__->set_primary_key('id');

1;
