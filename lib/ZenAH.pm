package ZenAH;

use strict;
use warnings;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the application's root
# directory
#
use Catalyst qw/-Debug ConfigLoader Static::Simple FormValidator DefaultEnd
                SubRequest/;

our $VERSION = '0.01';

#
# Start the application
#
__PACKAGE__->setup( qw/Static::Simple/ );
__PACKAGE__->config->{static}->{dirs} =
  [
   'static',
   qr!^(images|css|js|dojo)\/!,
  ];

=head1 NAME

ZenAH - Catalyst based application

=head1 SYNOPSIS

    script/zenah_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 SEE ALSO

L<ZenAH::Controller::Root>, L<Catalyst>

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
