#!/usr/bin/perl -w
#
# Copyright (C) 2008 by Mark Hindess

use strict;
use DirHandle;
use English qw/-no_match_vars/;
use FileHandle;
my %tests;
my $has_test_difference;

END {
  unlink 't/zenah.db';
}

BEGIN {
  $ENV{ZENAH_DBI_CONFIG}='t/dbi.conf';
  unlink 't/zenah.db';
  0 == system 'sqlite3 t/zenah.db <zenah.sample.sql3' or
    die "sqlite3 failed to create database: $! $@\n";
  sub read_request_data {
    my ($dir, $tests) = @_;
    my $rd = 't/'.$dir;
    my $dh = DirHandle->new('t/'.$dir) or
      die "Open of t/$dir directory: $ERRNO\n";
    foreach ($dh->read) {
      next if (/^\./);
      if (-d $rd.'/'.$_) {
        read_request_data($dir.'/'.$_, $tests);
        next;
      }
      next if (!/^(.*)\.txt$/);
      my $name = $LAST_PAREN_MATCH;
      my $f = $rd.'/'.$_;
      my $fh = FileHandle->new($f) or die "Failed to open $f: $ERRNO\n";
      my $request = <$fh>;
      chomp($request);
      my $content_type = <$fh>;
      chomp($content_type);
      my $status = <$fh>;
      chomp($status);
      local $RS; undef $RS;
      my $content = <$fh>;
      $fh->close;
      $tests->{$dir.'/'.$name} =
        {
         request => $request,
         content => $content,
         content_type => $content_type,
         status => $status,
        };
    }
    $dh->close;
  }
  my $dir = $ENV{ZENAH_ADMIN_TEST_DIR} || 'requests';
  read_request_data($dir, \%tests);
  require Test::More;
  import Test::More tests => (1+3*(scalar keys %tests));
  eval { require Test::Differences; import Test::Differences; };
  $has_test_difference = !$@;
}

use_ok 'Catalyst::Test', 'ZenAH';

foreach my $file (sort keys %tests) {
  my $req = $tests{$file}->{request};
  my $resp = request($req);
  is($resp->status_line, $tests{$file}->{status}, $req.' - status');
  is($resp->content_type, $tests{$file}->{content_type}, $req.' - status');
  my $got = canonical_content($resp->content);
  my $expected = canonical_content($tests{$file}->{content});
  if ($has_test_difference) {
    eq_or_diff $got, $expected, $file.' - content';
  } else {
    is($got, $expected, $file.' - content');
  }
}

sub canonical_content {
  my $s = $_[0];
  $s =~ s/\n\s*\n/\n/g;
  $s =~ s/^\s+//mg;
  $s =~ s/now =\&gt; \d+/now =\&gt; 1231343985/mg;
  $s =~ s/\&quot;time\&quot; =\&gt; \d+/\&quot;time\&quot; =\&gt; 1231343985/mg;
  $s =~ s/dt =\&gt; bless\({.*}, \&quot;DateTime\&quot;\),/dt =\&gt [snip],/msg;
  $s;
}
