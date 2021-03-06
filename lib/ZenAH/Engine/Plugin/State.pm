package ZenAH::Engine::Plugin::State;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::State - Perl extension for an ZenAH State Plugin

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

This plugin registers a 'state' stash with the following operations:

=over

=item C<get(type, name)>

Returns the state object (or first if there is more than one) with
the given type and name.

=item C<get_value(type, name)>

Returns the value from the state object (or first if there is more
than one) with the given type and name.

=item C<get_by_type(type)>

Returns a list of state objects with the given type.

=item C<get_by_type_matching(type, name_pattern)>

Returns a list of state objects with the given type with names that
match the given pattern.

=item C<get_by_type_since(type, modification_time)>

Returns a list of state objects with the given type and with
modification times equal or more recent than the given time.

=item C<get_by_type_since_matching(type, modification_time, name_pattern)>

Returns a list of state objects with the given type, with
modification times equal or more recent than the given time, and
with names that match the given pattern.

=item C<get_values_by_type(type)>

Returns the list of values from the objects that would be returned by
the C<get_by_type> call.

=item C<get_values_by_type_matching(type, name_pattern)>

Returns the list of values from the objects that would be returned by
the C<get_by_type_matching> call.

=item C<get_values_by_type_since(type, modification_time)>

Returns the list of values from the objects that would be returned by
the C<get_by_type_since> call.

=item C<get_values_by_type_since_matching(type, modification_time, pattern)>

Returns the list of values from the objects that would be returned by
the C<get_by_type_since_matching> call.

=item C<set(type, name, value)>

Updates the database with the new value or creates a new entry in the state
table.

=back

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  my %d =
    (
     get => sub {
       return ZenAH::CDBI::State->search(type => $_[0],
                                         name => $_[1])->first;
     },
     get_value => sub {
       my $state = ZenAH::CDBI::State->search(type => $_[0],
                                              name => $_[1])->first;
       return $state && $state->value;
     },
     get_by_type => sub {
       my @states = ZenAH::CDBI::State->search(type => $_[0]);
       return \@states;
     },
     get_by_type_matching => sub {
       my @states =
         grep
           { $_->name =~ /$_[1]/
           } ZenAH::CDBI::State->search(type => $_[0]);
       return \@states;
     },
     get_by_type_since => sub {
       my @states =
         ZenAH::CDBI::State->search(type => $_[0],
                                    mtime => { '>' => $_[1] });
       return \@states;
     },
     get_by_type_since_matching => sub {
       my @states =
         grep
           { $_->name =~ /$_[2]/
           } ZenAH::CDBI::State->search(type => $_[0],
                                        mtime => { '>' => $_[1] });
       return \@states;
     },
     get_values_by_type => sub {
       my @values =
         map { $_->value
             } ZenAH::CDBI::State->search(type => $_[0]);
       return \@values;
     },
     get_values_by_type_matching => sub {
       my @values =
         map { $_->value
             } grep
               { $_->name =~ /$_[1]/
               } ZenAH::CDBI::State->search(type => $_[0]);
       return \@values;
     },
     get_values_by_type_since => sub {
       my @values =
         map { $_->value
             } ZenAH::CDBI::State->search(type => $_[0],
                                          mtime => { '>' => $_[1] });
       return \@values;
     },
     get_values_by_type_since_matching => sub {
       my @values =
         map { $_->value
             } grep
               { $_->name =~ /$_[2]/
               } ZenAH::CDBI::State->search(type => $_[0],
                                            mtime => { '>' => $_[1] });
       return \@values;
     },
     set => sub {
       my $state = ZenAH::CDBI::State->find_or_create(type => $_[0],
                                                      name => $_[1]);
       my $old = $state->value();
       $state->value($_[2]);
       $state->mtime(time);
       $state->ctime(time) if (!defined $old || $old ne $_[2]);
       $state->update();
       return $state->value;
     },
    );

  $engine->add_stash(state => sub { return \%d });
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
