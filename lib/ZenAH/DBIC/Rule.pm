package ZenAH::DBIC::Rule;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('rule');
__PACKAGE__->add_columns(qw/id name trig type action active mtime ftime/);
__PACKAGE__->set_primary_key('id');

1;
