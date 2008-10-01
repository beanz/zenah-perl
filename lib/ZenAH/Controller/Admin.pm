package ZenAH::Controller::Admin;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

ZenAH::Controller::Admin - Admin Controller for this Catalyst based application

=head1 SYNOPSIS

See L<ZenAH>.

=head1 DESCRIPTION

Admin Controller for this Catalyst based application.

=head1 METHODS

=cut

=head2 default

=cut

my %crud =
  (
   'device' => {
     table => 'Device',
     column_order => [qw/name string description class/],
     sort_order => 'name',
     form_validation => {
       required => [ qw/name string class/ ],
       optional => [ qw/description/ ],
     },
     has_attributes => 1,
     has_controls => 1,
     has_rooms => 1,
     list_rows => 15,
   },
   'deviceattribute' => {
     table => 'DeviceAttribute',
     column_order => [qw/name value/],
     sort_order => 'name, value',
     form_validation => {
       required => [ qw/name value/ ],
     },
     filter_format => '%s%%',
     filter_field => 'name',
   },
   'devicecontrol' => {
     table => 'DeviceControl',
     column_order => [qw/class name string description definition/],
     sort_order => 'class, name',
     form_validation => {
       required => [ qw/class name string definition/ ],
       optional => [ qw/description/ ],
     },
     list_rows => 10,
   },
   'map' => {
     table => 'Map',
     column_order => [qw/class name value/],
     sort_order => 'class, name',
     form_validation => {
       required => [ qw/class name value/ ],
     },
   },
   'room' => {
     table => 'Room',
     column_order => [qw/name string description/],
     sort_order => 'name',
     form_validation => {
       required => [ qw/name string/ ],
       optional => [ qw/description/ ],
     },
     filter_method => 'none',
     has_attributes => 1,
     has_devices => 1,
   },
   'roomattribute' => {
     table => 'RoomAttribute',
     column_order => [qw/name value/],
     sort_order => 'name, value',
     form_validation => {
       required => [ qw/name value/ ],
     },
     filter_format => '%s%%',
     filter_field => 'name',
   },
   'rule' => {
     table => 'Rule',
     column_order => [qw/name active class trig action ftime mtime/],
     sort_order => 'name',
     form_validation => {
       required => [ qw/name class active/ ],
       optional => [ qw/trig action mtime/ ],
       constraint_methods => {
         class => qr/^(?:xpl|scene|at)$/,
         active => qr/^[01]$/,
       },
     },
     list_rows => 10,
   },
   'state' => {
     table => 'State',
     column_order => [qw/class name value ctime mtime/],
     sort_order => 'name',
     form_validation => {
       required => [ qw/class name value ctime mtime/ ]
     },
   },
   'template' => {
     table => 'Template',
     column_order => [qw/class name text/],
     sort_order => 'class,name',
     form_validation => {
       required => [ qw/class name text/ ]
     },
     list_rows => 5,
   },
  );

#
# Output a friendly welcome message
#
sub default : Private {
  my ( $self, $c ) = @_;

  my ($root, $type, $view, @args) = @{$c->request->arguments};

  unless ($type && exists $crud{$type}) {
    $type = 'device';
    $view = 'default';
    @args = ();
  }

  $c->stash(type => $type);
  $c->stash($_ => $crud{$type}->{$_}) foreach (keys %{$crud{$type}});
  $c->stash('fulltable' => 'ZenAH::Model::CDBI::'.$crud{$type}->{table});
  $c->forward('ZenAH::Controller::Admin::CRUD', $view||'default', @args)
}

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
