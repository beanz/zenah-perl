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

#
# Output a friendly welcome message
#
sub default : Private {
  my ( $self, $c ) = @_;

#  $c->response->body( $c->welcome_message );
  $c->forward('ZenAH::Controller::Admin::Device', 'default');
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
