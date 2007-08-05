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
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

# Preloaded methods go here.

sub new {
  my $pkg = shift;
  $pkg = ref($pkg) if (ref($pkg));
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
  $self->{_map} = \%m;
  $engine->add_stash(variable => "map",
                     callback => sub { $self->stash(@_); });
  return $self;
}

sub stash {
  my $self = shift;
  return $self->{_map};
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
