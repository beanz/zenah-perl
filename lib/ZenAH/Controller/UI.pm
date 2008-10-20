package ZenAH::Controller::UI;

use strict;
use base 'Catalyst::Controller';
use Template;
use xPL::Client;
use URI;
use URI::QueryParam;
use DateTime;

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

=head2 C<default>

Forwards to list.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('show');
}

=head2 C<show>

Shows a UI page

=cut

sub show : Local {
    my ( $self, $c ) = @_;
    my $template = ($c->request->path || 'html').'/layout';
    if ($template =~ /xul/) {
      $c->response->content_type('application/vnd.mozilla.xul+xml');
    }
    $c->stash->{now} = time;
    $c->stash->{dt} = DateTime->now;
    $c->stash->{status} = $c->request->param('status') || '&nbsp;';
    $c->stash->{template} = $template;
    $c->stash->{variant_url} = \&variant_url;
    $c->forward('ZenAH::View::UI');
}

=head2 C<text>

Shows a UI page

=cut

sub text : Local {
    my ( $self, $c ) = @_;
    my $template = $c->request->path;
    $template .= '/default' unless ($template =~ /\//);
    $c->response->content_type('text/plain');
    $c->stash->{now} = time;
    $c->stash->{dt} = DateTime->now;
    $c->stash->{template} = $template;
    $c->stash->{variant_url} = \&variant_url;
    $c->forward('ZenAH::View::UI');
}

=head2 C<json>

Shows a UI page

=cut

sub json : Local {
    my ( $self, $c ) = @_;
    my $template = $c->request->path;
    $template .= '/default' unless ($template =~ /\//);
    $c->response->content_type('text/json');
    $c->stash->{now} = time;
    $c->stash->{dt} = DateTime->now;
    $c->stash->{template} = $template;
    $c->stash->{variant_url} = \&variant_url;
    $c->forward('ZenAH::View::UI');
}

=head2 C<ajax>

Shows a UI page

=cut

sub ajax : Local {
    my ( $self, $c, $device_name, @action ) = @_;

    my $action;
    if ($device_name) {
      $action = join('/', @action);
    } else {
      ($device_name, $action) = $c->request->param('args');
    }

    my $device =
      ZenAH::Model::CDBI::Device->search(name => $device_name)->first;
    unless ($device) {
      $c->response->body("No such device, $device_name\n");
      return 1;
    }
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
      return 1;
    }
    $c->response->body($self->evaluate_action($definition,
                                              { device => $device }) ||
                       "Invoked action, $action, on device, $device_name\n");
}

=head2 C<action>

Shows a UI page

=cut

sub action : Local {
    my ( $self, $c, $device_name, @action ) = @_;
    my $action = join('/', @action);
    my $status = $c->subreq('/ajax/'.$device_name.'/'.$action);
    my $uri = URI->new($c->request->referer());
    $uri->query_param(status => $status);
    $c->response->redirect($uri, 303);
}

=head2 C<variant_url($catalyst, $name, \%hash)>

Returns a href with content, C<$name>, based on the current url but
with C<QUERY_STRING> parameters added (or replaced) for each entry in
the given hash.

=cut

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

=head2 C<evaluate_action($template_string, $template_stash)>

This method is used to process a template (with the given stash)
and run the resulting actions.

=cut

sub evaluate_action : Private {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $processed = $self->process_template($action, $stash);
  $processed =~ s/^\s*$//mg;
  return $self->run_action($processed, $stash);
}

=head2 C<run_action($action_string, $template_stash)>

This method executes a list of actions after it has been processed as
a template.

=cut

sub run_action : Private {
  my $self = shift;
  my $action = shift;
  my $stash = shift || {};
  my $result = '';
  my $remaining = $action;
  while ($remaining) {
    my $command;
    ($command, $remaining) = split(/\r?\n+/, $remaining, 2);
    next if ($command =~ /^\s*$/);
    $command =~ s/^\s+//;
    my ($type, $spec) = split(/\s+/, $command, 2);
    unless ($type =~ /^(xpl|error|info)$/) {
      die "no action defined for '$type'";
      next;
    }
    if ($type eq "error") {
      die $spec."\n";
    }
    if ($type eq 'info') {
      $result .= $spec."\n";
      next;
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
  return $result;
}

=head2 C<process_template($template_string, $template_stash)>

This method is applies the L<Template::Toolkit> to the given string
with the supplied stash.

=cut

sub process_template : Private {
  my $self = shift;
  my $input = shift or return;
  my $stash = shift || {};
  my $output = '';
  my $t = Template->new({ POST_CHOMP => 1, TRIM => 1, });
  $t->process(\$input, $stash, \$output) or
    die 'Template error: '.$t->error();
  return $output;
}

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
