package ZenAH::Engine::Plugin::Scene;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::Scene - Perl extension for an ZenAH Scene Plugin

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
use xPL::Base qw/simple_tokenizer/;

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

This plugin registers a 'scene' trigger - that does nothing since
scenes are always triggered by running the 'scene' action - and a
'scene' action, see L<action_scene()> below.

=cut

sub new {
  my $pkg = shift;
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};
  $engine->add_trigger(type => "scene"); # no-op
  $engine->add_action(type => "scene",
                      callback => sub { $self->action_scene(@_) });
  return $self;
}

=head2 C<action_scene(%params)>

This method is registered as a callback for the 'scene' action.  If it
is passed an odd number of arguments then the first is assumed to be
the name of the 'scene' rule to execute and any remaining arguments
are assumed to be a hash of parameters to pass to the action template
for the rule, otherwise the arguments are assumed to be a hash of
parameters to pass to the action template with 'name' key/value with
the name of the rule to execute.

=cut

sub action_scene {
  my $self = shift;
  my %p = @_;
  my $spec = $p{spec} or
    return $self->{_engine}->ouch("requires 'spec' parameter");
  my @args = simple_tokenizer($spec);
  my %stash;
  my $name;
  if (@args % 2) {
    $name = shift @args;
    %stash = @args;
  } else {
    %stash = @args;
    $name = $stash{name};
    delete $stash{name};
  }
  $self->{_engine}->trigger_rule_by_name($name, \%stash);
  return 1;
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
