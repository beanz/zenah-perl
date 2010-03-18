package ZenAH::DBIC::State;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('state');
__PACKAGE__->add_columns(qw/id name type value mtime ctime/);
__PACKAGE__->set_primary_key('id');

sub new {
  my ( $class, $attrs ) = @_;
  my $t = time;
  foreach (qw/ctime mtime/) {
    $attrs->{$_} = $t unless (defined $attrs->{mtime});
  }
  return $class->next::method($attrs);
}

sub store_column {
  my ( $self, $name, $value ) = @_;
  print STDERR "SC: @_\n";
  if ($name eq 'value') {
    my $t = time;
    $self->ctime($t) if ($self->is_changed_column('value'));
    $self->mtime($t);
  }
  $self->next::method($name, $value);
}

1;
