package ZenAH::Controller::UI;

use strict;
use base 'Catalyst::Controller';
use Template;
use xPL::Client;
use URI;
use URI::QueryParam;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

ZenAH::Controller::UI - UI Component

=head1 SYNOPSIS

See L<ZenAH>

=head1 DESCRIPTION

UI Component.

=head1 METHODS

=over 4

=item default

Forwards to list.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('show');
}

=item show

Shows a UI page

=cut

sub show : Local {
    my ( $self, $c ) = @_;
    my $template = ($c->request->path || 'html').'/layout';
    if ($template =~ /xul/) {
      $c->response->content_type('application/vnd.mozilla.xul+xml');
    }
    my $status = $c->request->param('status');
    if (defined $status && !$c->request->user_agent() =~ /PlayStation/) {
      my $uri = URI->new($c->request);
      $uri->query_param_delete('status');
      $c->stash->{meta_refresh} = '5;'.$uri;
    }
    $c->stash->{now} = time;
    $c->stash->{status} = $status || '&nbsp;';
    $c->stash->{template} = $template;
    $c->stash->{variant_url} = \&variant_url;
    $c->forward('ZenAH::View::UI');
}

=item sql

Shows a UI page

=cut

sub sql : Local {
    my ( $self, $c ) = @_;
    my $template = 'sql/'.($c->request->path || 'default');
    $c->response->content_type('text/plain');
    $c->stash->{now} = time;
    $c->stash->{template} = $template;
    $c->stash->{variant_url} = \&variant_url;
    $c->forward('ZenAH::View::UI');
}

=item ajax

Shows a UI page

=cut

sub ajax : Local {
    my ( $self, $c, $device_name, $action ) = @_;

    ($device_name, $action) = $c->request->param('args') unless ($device_name);

    my $device =
      ZenAH::Model::CDBI::Device->search(name => $device_name)->first;
    die 'No such device, ', $device_name, "\n" unless ($device);
    my $type_name = $device->type;
    my $control =
      $device->device_controls("device_control.name" => $action)->first;
    $action =~ s/[^-a-z0-9_\.]/_/ig;
    my $definition;
    if ($control) {
      $definition = $control->definition;
    } elsif ($type_name eq "Button") {
      $definition =
        "xpl -m xpl-trig -c remote.basic device=[% device.name %] keys=$action";
    } elsif ($type_name eq "DMX") {
      $definition =
        "xpl -m xpl-cmnd -c dmx.basic base=[% device.attribute('base') %] ".
          "type=set value=$action";
    } else {
      $c->response->body("Invalid action, $action, on device, $device_name\n");
    }
    $self->evaluate_action($definition, { device => $device });
    $c->response->body("Invoked action, $action, on device, $device_name\n");
}

=item action

Shows a UI page

=cut

sub action : Local {
    my ( $self, $c, $device_name, $action ) = @_;
    my $status = $c->subreq('/ajax/'.$device_name.'/'.$action);
    my $uri = URI->new($c->request->referer());
    $uri->query_param(status => $status);
    $c->response->redirect($uri, 303);
}

sub variant_url {
  my $catalyst = shift;
  my $name = shift;
  my $v = shift;
  my $uri = $catalyst->request->uri->clone;
  foreach (keys %$v) {
    $uri->query_param($_ => $v->{$_});
  }
  return '<a href="'.$uri.'">'.$name.'</a>';
}

sub evaluate_action : Private {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $processed = $self->process_template($action, $stash);
  $processed =~ s/^\s*$//mg;
  return $self->run_action($processed, $stash);
}

sub run_action : Private {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $command;
  my $remaining = $action;
  while ($remaining &&
         (($command, $remaining) = split(/\r?\n+/, $remaining, 2))) {
    next if ($command =~ /^\s*$/);
    $command =~ s/^\s+//;
    my ($type, $spec) = split(/\s+/, $command, 2);
    unless ($type =~ /^(xpl|error)$/) {
      die "no action defined for '$type'";
      next;
    }
    if ($type eq "error") {
      die $spec."\n";
    }
    print STDERR "Action: ", $type, " ", $spec, "\n";
    my %args =
      (
       vendor_id => "bnz",
       device_id => "zenahcgi",
       instance_id => $$,
      );
    my $xpl = xPL::Client->new(%args) or die "Failed to create xPL::Client";
    $xpl->send_from_string($spec);
  }
  return 1;
}

sub process_template : Private {
  my $self = shift;
  my $input = shift or return;
  my $stash = shift || {};
  my $output = '';
  my $t = Template->new({ POST_CHOMP => 1, TRIM => 1, });
  $t->process(\$input, $stash, \$output) or
    die 'Template error: '.$self->{_template}->error();
  return $output;
}

=back

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
