package ZenAH::Controller::History;

use strict;
use base 'Catalyst::Base';
use Data::Page;

=head1 NAME

ZenAH::Controller::History - Scaffolding Controller Component

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
  $c->stash->{column_order} = [qw/type name value ctime mtime/];
  $c->stash->{template} = 'History/add.tt';
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
    ZenAH::Model::CDBI::History->retrieve($id)->delete;
    $c->forward('list');
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Local {
    my ( $self, $c ) = @_;
    $c->form( optional => [ ZenAH::Model::CDBI::History->columns ] );
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields. '.
        'The following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in. '.
        'The following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
	ZenAH::Model::CDBI::History->create_from_form( $c->form );
    	return $c->forward('list');
    }
    $c->forward('add');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->form( optional => [ ZenAH::Model::CDBI::History->columns ] );
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'.
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are not correctly filled in.'.
        'the following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
    } else {
	ZenAH::Model::CDBI::History->retrieve($id)->update_from_form( $c->form );
	$c->stash->{message}='Updated OK';
    }
    $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Local {
  my ( $self, $c, $id ) = @_;
  $c->stash->{item} = ZenAH::Model::CDBI::History->retrieve($id);
  $c->stash->{column_order} = [qw/type name value ctime mtime/];
  $c->stash->{template} = 'History/edit.tt';
}

=item list

Sets a template.

=cut

sub list : Local {
    my ( $self, $c ) = @_;
    my %types = map { $_ => 1 } ZenAH::Model::CDBI::History->types();
    my $page = $c->req->param('page') || 1;
    my $rows = $c->req->param('rows') || 20;
    my $like = '%';
    my $filter = $c->req->param('filter');
    if ($filter && exists $types{$filter}) {
      $like = $filter;
    } else {
      $filter = 'none';
    }
    my $dist = ZenAH::CDBI::History->distinct($like);
    my $count = scalar @$dist;
    my $page = Data::Page->new($count, $rows, $page);
    my @items;
    foreach my $i ($page->splice($dist)) {
      push @items, ZenAH::CDBI::History->search_most_recent(@$i)->first;
    }
    $c->stash->{page} = $page;
    $c->stash->{items} = \@items;
    $c->stash->{filters} = ['none', sort keys %types];
    $c->stash->{filter} = $filter;
    $c->stash->{column_order} = [qw/type name value ctime mtime/];
    $c->stash->{template} = 'History/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local {
    my ( $self, $c, $id ) = @_;
    my $first = ZenAH::Model::CDBI::History->retrieve($id);
    my $page = $c->req->param('page') || 1;
    my $rows = $c->req->param('rows') || 20;
    ($c->stash->{page},
     $c->stash->{items}) =
       ZenAH::Model::CDBI::History->page(type => $first->type,
                                         name => $first->name,
                                         {
                                          order_by => '-mtime',
                                          page => $page,
                                          rows => $rows,
                                         }
                                        );
    $c->stash->{column_order} = [qw/type name value ctime mtime/];
    $c->stash->{template} = 'History/view.tt';
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
