package ZenAH::Controller::Admin::Map;

use strict;
use base 'Catalyst::Base';

=head1 NAME

ZenAH::Controller::Admin::Map - Scaffolding Controller Component

=head1 SYNOPSIS

See L<ZenAH>

=head1 DESCRIPTION

Scaffolding Controller Component.

=head1 METHODS

=over 4

=item add

Sets a template.

=cut

sub add : Local {
    my ( $self, $c ) = @_;
    $c->stash->{column_order} = [qw/type name value/];
    $c->stash->{template} = 'Map/add.tt';
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

sub destroy : Local {
    my ( $self, $c, $id ) = @_;
    ZenAH::Model::CDBI::Map->retrieve($id)->delete;
    $c->forward('list');
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Local {
    my ( $self, $c ) = @_;
    $c->form( optional => [ ZenAH::Model::CDBI::Map->columns ] );
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields. '.
        'The following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in. '.
        'The following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
	ZenAH::Model::CDBI::Map->create_from_form( $c->form );
    	return $c->forward('list');
    }
    $c->forward('add');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->form( optional => [ ZenAH::Model::CDBI::Map->columns ] );
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'.
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in.'.
        'the following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
	ZenAH::Model::CDBI::Map->retrieve($id)->update_from_form( $c->form );
	$c->stash->{message}='Updated OK';
    }
    $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = ZenAH::Model::CDBI::Map->retrieve($id);
    $c->stash->{column_order} = [qw/type name value/];
    $c->stash->{template} = 'Map/edit.tt';
}

=item list

Sets a template.

=cut

sub list : Local {
    my ( $self, $c ) = @_;
    my %types = map { $_ => 1 } ZenAH::Model::CDBI::Map->types();
    my $page = $c->req->param('page') || 1;
    my $rows = $c->req->param('rows') || 20;
    my %search = ();
    my $filter = $c->req->param('filter');
    if ($filter && exists $types{$filter}) {
      $search{type} = $filter;
    } else {
      $filter = 'none';
    }
    ($c->stash->{page},
     $c->stash->{items}) =
       ZenAH::Model::CDBI::Map->page(\%search,
                                     {
                                      order_by => 'type, name',
                                      page => $page,
                                      rows => $rows,
                                     }
                                    );
    $c->stash->{filters} = ['none', sort keys %types];
    $c->stash->{filter} = $filter;
    $c->stash->{column_order} = [qw/type name value/];
    $c->stash->{template} = 'Map/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = ZenAH::Model::CDBI::Map->retrieve($id);
    $c->stash->{column_order} = [qw/type name value/];
    $c->stash->{template} = 'Map/view.tt';
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