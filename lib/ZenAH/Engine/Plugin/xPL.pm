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
use xPL::Base qw/simple_tokenizer/;

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
  my $self = {};
  bless $self, $pkg;

  my %p = @_;
  my $engine = $self->{_engine} = $p{engine};

  $engine->add_trigger(class => "xpl",
                       add_callback => sub { $self->add(@_) },
                       remove_callback => sub { $self->remove(@_) });

  $engine->add_action(class => "xpl",
                      callback => sub { $self->xpl_send(@_) });
  return $self;
}

sub add {
  my ($self, $rule) = @_;
  my %filter = simple_tokenizer($rule->trig);
  if (exists $filter{class} && $filter{class} =~ /^(\w+)\.(\w+)$/) {
    $filter{class} = $1;
    $filter{class_type} = $2;
  }
  if ($filter{'device'} && $filter{'device'} =~ /^lookup_(\w+)\[([^]]+)\]$/) {
    if ($1 eq 'map') {
      my $arg = $2;
      $filter{'device'} =
        sub { ZenAH::CDBI::Map->search(class => $arg, name => $_[0])->first };
    } else {
      my $lookup = 'search_'.$1;
      my @arg = split /,/, $2;
      $filter{'device'} =
        sub {
          my $res;
          eval { $res = ZenAH::CDBI::Device->$lookup(@arg, $_[0]) };
          warn $rule->name." lookup error: $@\n" if ($@);
          return $res;
        };
    }
  }

  $self->{_engine}->add_xpl_callback(id => 'trigger-for-rule-'.$rule,
                                     targetted => 0,
                                     self_skip => 0,
                                     filter => \%filter,
                                     callback => sub {
                                       return $self->fire($rule, @_)
                                     });
  return 1;
}

sub remove {
  my ($self, $rule) = @_;
  $self->{_engine}->remove_xpl_callback('trigger-for-rule-'.$rule);
  return 1;
}

sub fire {
  my $self = shift;
  my $rule = shift;
  my %p = @_;
  $self->{_engine}->trigger_rule($rule, { xpl => $p{message} });
  return 1;
}

sub xpl_send {
  my $self = shift;
  my %p = @_;
  my $spec = $p{spec} or return $self->{_engine}->ouch("requires 'spec' parameter");
  eval {
    $self->{_engine}->send_from_string($spec);
  };
  $self->{_engine}->ouch($@) if ($@);
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

Copyright (C) 2007 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
