package ZenAH::Engine::Plugin::History;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::History - Perl extension for an ZenAH History Plugin

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
  my %d =
    (
     get => sub {
       return ZenAH::CDBI::History->search(type => $_[0],
                                           name => $_[1])->first;
     },
     get_value => sub {
       my $history = ZenAH::CDBI::History->search(type => $_[0],
                                                  name => $_[1])->first;
       return $history && $history->value;
     },
     get_by_type => sub {
       my @historys = ZenAH::CDBI::History->search(type => $_[0]);
       return \@historys;
     },
     get_by_type_matching => sub {
       my @historys =
         grep
           { $_->name =~ /$_[1]/
           } ZenAH::CDBI::History->search(type => $_[0]);
       return \@historys;
     },
     get_by_type_since => sub {
       my @historys =
         ZenAH::CDBI::History->search(type => $_[0],
                                      mtime => { '>' => $_[1] });
       return \@historys;
     },
     get_by_type_since_matching => sub {
       my @historys =
         grep
           { $_->name =~ /$_[2]/
           } ZenAH::CDBI::History->search(type => $_[0],
                                          mtime => { '>' => $_[1] });
       return \@historys;
     },
     get_values_by_type => sub {
       my @values =
         map { $_->value
             } ZenAH::CDBI::History->search(type => $_[0]);
       return \@values;
     },
     get_values_by_type_matching => sub {
       my @values =
         map { $_->value
             } grep
               { $_->name =~ /$_[1]/
               } ZenAH::CDBI::History->search(type => $_[0]);
       return \@values;
     },
     get_values_by_type_since => sub {
       my @values =
         map { $_->value
             } ZenAH::CDBI::History->search(type => $_[0],
                                            mtime => { '>' => $_[1] });
       return \@values;
     },
     get_values_by_type_since_matching => sub {
       my @values =
         map { $_->value
             } grep
               { $_->name =~ /$_[2]/
               } ZenAH::CDBI::History->search(type => $_[0],
                                              mtime => { '>' => $_[1] });
       return \@values;
     },
     add => sub {
       my $history =
         ZenAH::CDBI::History->find_or_create(type => $_[0],
                                              name => $_[1],
                                              value => $_[2],
                                              ctime => $_[3] || DateTime->now);
       $history->mtime($history->ctime);
       $history->update();
       return 1;
     },
     add_minimal => sub {
       my $old =
         ZenAH::CDBI::History->search(type => $_[0],
                                      name => $_[1],
                                      { order_by => '-ctime' })->first;
       if ($old and $old->value eq $_[2]) {
         $old->mtime($_[3] || DateTime->now);
         $old->update();
       } else {
         my $time = $_[3] || DateTime->now;
         my $history =
           ZenAH::CDBI::History->insert({type => $_[0],
                                         name => $_[1],
                                         value => $_[2],
                                         ctime => $time,
                                         mtime => $time});
       }
       return 1;
     },
    );

  $engine->add_stash(variable => "history",
                     callback => sub { return \%d });
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
