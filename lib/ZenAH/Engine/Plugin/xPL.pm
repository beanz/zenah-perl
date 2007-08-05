package ZenAH::Engine::Plugin::xPL;

# $Id$

=head1 NAME

ZenAH::Engine::Plugin::xPL - Perl extension for an ZenAH xPL Plugin

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
use xPL::Message;
use xPL::Base;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(xPL::Base);
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

  $engine->add_trigger(type => "xpl",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) });

  $engine->add_action(type => "xpl",
                      callback => sub { $self->xpl_send(@_) });
  return $self;
}

sub add {
  my $self = shift;
  my %p = @_;
  exists $p{rule} or $self->argh("requires 'rule' parameter");
  exists $p{trigger} or $self->argh("requires 'trigger' parameter");
  my $rule = $p{rule}->id;
  my $trigger = $p{trigger};

  $self->{_engine}->add_xpl_callback(id => 'trigger-for-rule-'.$rule,
                                     targetted => 0,
                                     self_skip => 0,
                                     filter => $trigger,
                                     callback => sub {
                                       return $self->fire($rule, @_)
                                     });
  return 1;
}

sub remove {
  my $self = shift;
  my %p = @_;
  exists $p{rule} or $self->argh("requires 'rule' parameter");
  $self->{_engine}->remove_xpl_callback('trigger-for-rule-'.$p{rule});
  return 1;
}

sub fire {
  my $self = shift;
  my $rule = shift;
  my %p = @_;
  $self->{_engine}->trigger_rule_by_id($rule, { xpl => $p{message} });
  return 1;
}

sub xpl_send {
  my $self = shift;
  my %p = @_;
  exists $p{spec} or return $self->ouch("requires 'spec' parameter");
  my $spec = $p{spec};
  eval {
    $self->{_engine}->send_from_string($spec);
  };
  $self->ouch($@) if ($@);
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
