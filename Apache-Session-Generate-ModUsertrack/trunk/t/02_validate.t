use strict;
use Test::More tests => 1;

use Apache::Session::Generate::ModUsertrack;

my $id = '127.0.0.1.00000000000000000';
my $session = bless { data => { _session_id => $id }, }, 'Apache::Session';
Apache::Session::Generate::ModUsertrack::validate($session);

ok 1, 'validation ok';






