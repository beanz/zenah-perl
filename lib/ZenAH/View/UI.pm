package ZenAH::View::UI;

use strict;
use base 'Catalyst::View::TT';
use ZenAH::Templates;

__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    LOAD_TEMPLATES => [ ZenAH::Templates->new(
                                              COMPILE_DIR  => '/tmp/tt',
                                              COMPILE_EXT  => '.ttc',
                                             ) ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'site/error',
    TRIM         => 1,
    TIMER        => 0,
});

=head1 NAME

ZenAH::View::UI - Catalyst TTSite View

=head1 SYNOPSIS

See L<ZenAH>

=head1 DESCRIPTION

Catalyst TTSite View.

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
