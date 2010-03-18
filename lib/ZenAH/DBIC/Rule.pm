package ZenAH::DBIC::Rule;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('rule');
__PACKAGE__->add_columns(qw/id name trig type action active mtime ftime/);
__PACKAGE__->set_primary_key('id');

use overload '""' => sub { ref($_[0]).':'.$_[0]->id }, fallback => 1;

1;
