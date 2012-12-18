package ZenAH::Engine::Plugin::Maps;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::Maps - Perl extension for an ZenAH Maps Plugin

=head1 SYNOPSIS

  # Loaded by ZenAH::Engine

=head1 DESCRIPTION

This is a module for the Zen Automated Home Engine.  It provides a
main loop and allows callbacks to be registered for events that
occur.  It also configures the L<ZenAH::Engine::Plugin>.

The event loop does not fork.  Therefore all callbacks must either be
short or they should fork.  For example, a callback that needed to
make an HTTP request could connect and send the request then add the
socket handle to receive the response to the engine event loop with a
suitable callback to handle the reply.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;
use ZenAH::CDBI;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

# Preloaded methods go here.

=head2 C<new(%params)>

The constructor creates a new plugin object.  The constructor takes a
parameter hash as arguments.  Valid parameters in the hash are:

=over

=item engine

This is a reference to the engine that is instantiating the plugin.

=back

It returns a blessed reference when successful or undef otherwise.

This plugin registers a 'map' stash with the following operations:

=over

=item C<lookup(type, name>

Returns the value of the specified map entry or undef if no such entry
exists.

=item C<reverse(type, value)>

Returns the name of the specified map entry or undef if no such entry
exists.

=item C<lookup_list(type, name>

Returns a list of values of any matching map entries.

=item C<reverse_list(type, value)>

Returns a list of names of any matching map entries.

=back

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};

  my %m =
    (
     lookup => sub {
       my $r = ZenAH::CDBI::Map->search(type => $_[0],
                                        name => $_[1])->first;
       return $r ? $r->value : undef;
     },
     reverse => sub {
       my $r = ZenAH::CDBI::Map->search(type => $_[0],
                                        value => $_[1])->first;
       return $r ? $r->name : undef;
     },
     lookup_list => sub {
       map { $_->value } ZenAH::CDBI::Map->search(type => $_[0],
                                                  name => $_[1]);
     },
     reverse_list => sub {
       map { $_->name } ZenAH::CDBI::Map->search(type => $_[0],
                                                 value => $_[1]);
     },
     all => sub {
       map { { name => $_->name,
                 value => $_->value }
           } ZenAH::CDBI::Map->search(type => $_[0]);
     },
    );
  $engine->add_stash('map' => sub { \%m });
  return $self;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 EXPORT

None by default.

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
