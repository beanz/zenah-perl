use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ZenAH' }
BEGIN { use_ok 'ZenAH::Controller::Map' }

ok( request('/map')->is_success, 'Request should succeed' );


