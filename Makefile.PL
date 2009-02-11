use inc::Module::Install;

name 'ZenAH';
all_from 'lib/ZenAH.pm';

requires Catalyst => '5.64';
requires 'Template::Provider' => '2.93';
requires 'xPL::Base' => '0.05';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::SubRequest';
requires 'Class::DBI::FromForm';
requires 'Class::DBI::AsForm';
requires 'Class::DBI::Loader';
requires 'Class::DBI::Loader::Relationship';
requires 'Class::DBI::Sweet';
requires 'DateTime::Format::Strptime';
requires 'Template::Plugin::Class';

build_requires 'Module::Install';
build_requires 'DBD::SQLite' => undef;
build_requires 'Class::DBI::SQLite' => undef;
build_requires  'Test::More' => undef;
build_requires  'Test::Differences' => undef;
build_requires  'Test::WWW::Mechanize' => undef;

catalyst;

install_script glob('script/*.pl');
install_script 'bin/zenah';
install_script 'bin/hr10-label';
install_script 'bin/ss13e-label';
auto_install;
WriteAll;
open F, "<Makefile.local" or exit(0);
open M, ">>Makefile" or exit(0);
while (<F>) {
  print M;
}
close M;
close F;
