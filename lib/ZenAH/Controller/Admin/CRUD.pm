package ZenAH::Controller::Admin::CRUD;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

ZenAH::Controller::Admin::CRUD - Scaffolding Controller Component

=head1 SYNOPSIS

See L<ZenAH>

=head1 DESCRIPTION

Scaffolding Controller Component.

=head1 METHODS

=over 4

=item add

Sets a template.

=cut

sub add : Private {
  my ( $self, $c ) = @_;
  $c->stash->{template} = 'CRUD/add.tt';
}

=item default

Forwards to list.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

=item destroy

Destroys a row and forwards to list.

=cut

sub destroy : Private {
    my ( $self, $c, $id ) = @_[0,1,5];
    $c->stash->{fulltable}->retrieve($id)->delete;
    $c->response->redirect($c->uri_for($c->stash->{type}, 'list'), 303);
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Private {
    my ( $self, $c ) = @_;
    $c->form(%{$c->stash->{form_validation}});
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields. '.
        'The following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in. '.
        'The following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
	$c->stash->{fulltable}->create_from_form( $c->form );
        return
          $c->response->redirect($c->uri_for($c->stash->{type}, 'list'), 303);
    }
    $c->forward('add');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Private {
    my ( $self, $c, $id ) = @_[0,1,5];
    $c->form(%{$c->stash->{form_validation}});
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'.
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in.'.
        'the following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
        my $type = $c->stash->{type};
	$c->stash->{fulltable}->retrieve($id)->update_from_form( $c->form );
	if ($c->stash->{has_attributes}) {
          my $attr_table = $c->stash->{fulltable}.'Attribute';
          my $link_table = $attr_table.'Link';
          my $attr_type = $type.'_attribute';
          my %attr = map { $_ => 1 } $c->req->param('attrs');
          foreach my $a ($attr_table->retrieve_all()) {
            if (exists $attr{$a}) {
              $link_table->find_or_create(
                  {
                   $type => $id,
                   $attr_type => $a,
                  });
            } else {
              my $link =
                $link_table->search(
                    $type => $id,
                    $attr_type => $a)->first();
              $link->delete if ($link);
            }
          }
        }
	if ($c->stash->{has_rooms}) {
          my $room_table = 'ZenAH::Model::CDBI::Room';
          my $link_table = $room_table.$c->stash->{table}.'Link';
          my %room = map { $_ => 1 } $c->req->param('rooms');
          foreach my $r ($room_table->retrieve_all()) {
            if (exists $room{$r}) {
              $link_table->find_or_create(
                  {
                   $type => $id,
                   room => $r,
                  });
            } else {
              my $link =
                $link_table->search(
                    $type => $id,
                    room => $r)->first();
              $link->delete if ($link);
            }
          }
        }
	if ($c->stash->{has_controls}) {
          my $ctrl_table = $c->stash->{fulltable}.'Control';
          my $link_table = $ctrl_table.'Link';
          my $ctrl_type = $type.'_Control';
          my %ctrl = map { $_ => 1 } $c->req->param('controls');
          foreach my $c ($ctrl_table->retrieve_all()) {
            if (exists $ctrl{$c}) {
              $link_table->find_or_create(
                  {
                   $type => $id,
                   $ctrl_type => $c,
                  });
            } else {
              my $ctrllink =
                $link_table->search(
                    $type => $id,
                    $ctrl_type => $c)->first();
              $ctrllink->delete if ($ctrllink);
            }
          }
        }
	$c->stash->{message}='Updated OK';
    }
    $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Private {
  my ( $self, $c, $id ) = @_[0,1,5];
  my $item = $c->stash->{item} = $c->stash->{fulltable}->retrieve($id);
  if ($c->stash->{has_attributes}) {
    $c->stash->{attrs} = { map { $_ => 1 } $item->attributes() };
  }
  if ($c->stash->{has_rooms}) {
    $c->stash->{rooms} = { map { $_ => 1 } $item->rooms() };
  }
  if ($c->stash->{has_controls}) {
    $c->stash->{controls} = { map { $_ => 1 } $item->controls() };
  }
  $c->stash->{template} = 'CRUD/edit.tt';
}

=item copy

Sets a template.

=cut

sub copy : Private {
  my ( $self, $c, $id ) = @_[0,1,5];
  my $item = $c->stash->{item} = $c->stash->{fulltable}->retrieve($id);
  $c->forward('add');
}

=item list

Sets a template.

=cut

sub list : Private {
    my ( $self, $c ) = @_;
    my $page = $c->req->param('page') || 1;
    my $rows = $c->req->param('rows') || $c->stash->{list_rows} || 20;
    my %search = ();
    my $filter_method = $c->stash->{filter_method} || 'types';
    if ($filter_method ne 'none') {
      my %types = map { $_ => 1 } $c->stash->{fulltable}->$filter_method();
      my $filter = $c->req->param('filter');
      if ($filter && exists $types{$filter}) {
        $search{$c->stash->{filter_field} || 'type'} =
          { -like => (sprintf $c->stash->{filter_format} || '%s', $filter) };
      } else {
        $filter = 'none';
      }
      $c->stash->{filters} = ['none', sort keys %types];
      $c->stash->{filter} = $filter;
    }
    ($c->stash->{page},
     $c->stash->{items}) =
       $c->stash->{fulltable}->page(\%search,
                                       {
                                        order_by => $c->stash->{sort_order},
                                        page => $page,
                                        rows => $rows,
                                       }
                                      );
    $c->stash->{template} = 'CRUD/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Private {
  my ( $self, $c, $id ) = @_[0,1,5];
  my $item = $c->stash->{item} = $c->stash->{fulltable}->retrieve($id);
  $c->stash->{template} = 'CRUD/view.tt';
}

=back

=head1 SEE ALSO

Project website: http://www.zenah.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>zenah@beanz.uklinux.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
