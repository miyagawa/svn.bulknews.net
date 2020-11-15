use strict;
use Test::More tests => 2;

use CGI;
use CGI::BufferedHeader;

my $q = CGI::BufferedHeader->new(CGI->new);

ok $q->can('header_out'), 'can do header_out';
$q->header_out(Cookie => 'foobar');

my $header = $q->header(-type => 'text/html');
like $header, qr/Set-Cookie: foobar/, 'cookie';



