use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Mixxi' }
BEGIN { use_ok 'Mixxi::Controller::URL' }

ok( request('/url')->is_success, 'Request should succeed' );


