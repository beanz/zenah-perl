package ZenAH::Controller::Admin::Device;

use strict;
use base 'Catalyst::Base';

=head1 NAME

ZenAH::Controller::Admin::Device - Scaffolding Controller Component

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
  $c->stash->{column_order} = [qw/name string description type/];
  $c->stash->{template} = 'Device/add.tt';
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
  ZenAH::Model::CDBI::Device->retrieve($id)->delete;
  $c->forward('list');
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Local {
  my ( $self, $c ) = @_;
  $c->form( optional => [ ZenAH::Model::CDBI::Device->columns ] );
  if ($c->form->has_missing) {
    $c->stash->{message}='You have to fill in all fields. '.
      'The following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
  } elsif ($c->form->has_invalid) {
    $c->stash->{message}='Some fields are not correctly filled in. '.
      'The following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
  } else {
    ZenAH::Model::CDBI::Device->create_from_form( $c->form );
    return $c->forward('list');
  }
  $c->forward('add');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Local {
  my ( $self, $c, $id ) = @_;
  $c->form( optional => [ ZenAH::Model::CDBI::Device->columns ] );
  if ($c->form->has_missing) {
    $c->stash->{message}='You have to fill in all fields.'.
      'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
  } elsif ($c->form->has_invalid) {
    $c->stash->{message}='Some fields are not correctly filled in.'.
      'the following are invalid: <b>'.
	join(', ',$c->form->invalid()).'</b>';
  } else {
    ZenAH::Model::CDBI::Device->retrieve($id)->update_from_form( $c->form );
    my %room = map { $_ => 1 } $c->req->param('rooms');
    foreach my $r (ZenAH::Model::CDBI::Room->retrieve_all()) {
      if (exists $room{$r}) {
        ZenAH::Model::CDBI::RoomDeviceLink->find_or_create({
                                                            device => $id,
                                                            room => $r,
                                                           });
      } else {
        my $roomlink =
          ZenAH::Model::CDBI::RoomDeviceLink->search(device => $id,
                                                     room => $r)->first();
        $roomlink->delete if ($roomlink);
      }
    }
    my %attr = map { $_ => 1 } $c->req->param('attrs');
    foreach my $a (ZenAH::Model::CDBI::DeviceAttribute->retrieve_all()) {
      if (exists $attr{$a}) {
        ZenAH::Model::CDBI::DeviceAttributeLink->find_or_create(
            {
             device => $id,
             device_attribute => $a,
            });
      } else {
        my $attrlink =
          ZenAH::Model::CDBI::DeviceAttributeLink->search(
              device => $id,
              device_attribute => $a)->first();
        $attrlink->delete if ($attrlink);
      }
    }
    my %control = map { $_ => 1 } $c->req->param('controls');
    foreach my $a (ZenAH::Model::CDBI::DeviceControl->retrieve_all()) {
      if (exists $control{$a}) {
        ZenAH::Model::CDBI::DeviceControlLink->find_or_create(
            {
             device => $id,
             device_control => $a,
            });
      } else {
        my $controllink =
          ZenAH::Model::CDBI::DeviceControlLink->search(
              device => $id,
              device_control => $a)->first();
        $controllink->delete if ($controllink);
      }
    }
    $c->stash->{message}='Updated OK';
  }
  $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Local {
  my ( $self, $c, $id ) = @_;
  my $device = $c->stash->{item} = ZenAH::Model::CDBI::Device->retrieve($id);
  $c->stash->{rooms} = { map { $_ => 1 } $device->rooms() };
  $c->stash->{attrs} = { map { $_ => 1 } $device->device_attributes() };
  $c->stash->{controls} = { map { $_ => 1 } $device->device_controls() };
  $c->stash->{column_order} = [qw/name string description type/];
  $c->stash->{template} = 'Device/edit.tt';
}

=item list

Sets a template.

=cut

sub list : Local {
  my ( $self, $c ) = @_;
  my %types = map { $_ => 1 } ZenAH::Model::CDBI::Device->types();
  my $page = $c->req->param('page') || 1;
  my $rows = $c->req->param('rows') || 15;
  my %search = ();
  my $filter = $c->req->param('filter');
  if ($filter && exists $types{$filter}) {
    $search{type} = $filter;
  } else {
    $filter = 'none';
  }
  ($c->stash->{page},
   $c->stash->{items}) =
     ZenAH::Model::CDBI::Device->page(\%search,
                                      {
                                       order_by => 'name',
                                       page => $page,
                                       rows => $rows,
                                      }
                                     );
  $c->stash->{filters} = ['none', sort keys %types];
  $c->stash->{filter} = $filter;
  $c->stash->{column_order} = [qw/name string description type/];
  $c->stash->{template} = 'Device/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local {
  my ( $self, $c, $id ) = @_;
  my $device = $c->stash->{item} = ZenAH::Model::CDBI::Device->retrieve($id);
  my @rooms = $device->rooms();
  $c->stash->{num_rooms} = scalar @rooms;
  $c->stash->{column_order} = [qw/name string description type/];
  $c->stash->{template} = 'Device/view.tt';
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
