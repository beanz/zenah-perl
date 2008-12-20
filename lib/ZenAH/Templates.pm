package ZenAH::Templates;

# $Id$

=head1 NAME

ZenAH::Templates - Perl extension for the Zen Automated Template Provider

=head1 SYNOPSIS

  use ZenAH::Templates;

  __PACKAGE__->config({
      CATALYST_VAR => 'Catalyst',
      LOAD_TEMPLATES => [ ZenAH::Templates->new() ],
      PRE_PROCESS  => 'config/main',
      WRAPPER      => 'site/wrapper',
      ERROR        => 'site/error',
      TRIM         => 1,
      TIMER        => 0
  });

=head1 DESCRIPTION

This is a module for the Zen Automated Home (ZenAH) Template Provider.
It allows templates for the user interface to be loaded from the
ZenAH database (rather than from "static" files).

=head1 METHODS

=cut

use base Template::Provider;
use ZenAH::CDBI;

sub _init {
  my $self = shift;
  my $p = shift;
  $self->SUPER::_init(@_);
}

sub _template_modified {
  my $self = shift;
  my $path = shift;
  $path =~ s!^\.\/!!;
  my ($type, $name) = split /\//, $path, 2;
  my $t = ZenAH::CDBI::Template->search(type => $type, name => $name)->first;
  unless ($t) {
    warn "ZenAH::Template: can't find: $path\n";
    return;
  }
#  print STDERR "ZenAH::Templates(mod): found $path\n";
  return $t->mtime;
}

sub _template_content {
  my $self = shift;
  my $path = shift;
  $path =~ s!^\.\/!!;
  my ($type, $name) = split /\//, $path, 2;
  my $t = ZenAH::CDBI::Template->search(type => $type, name => $name)->first;
  unless ($t) {
    warn "ZenAH::Template: can't find: $path\n";
    return wantarray ? (undef, $path.': not found', time) : undef;
  }
#  print STDERR "ZenAH::Templates found $path\n";
  return wantarray ? ($t->text, undef, $t->mtime) : $t->text;
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
