use strict;
use Test::More tests => 5;

use CGI;
use CGI::BufferedHeader;

my $q = CGI::BufferedHeader->new(CGI->new);
ok $q->isa('CGI::BufferedHeader'), 'instance';

ok $q->can('add_header'), 'can do add_header';
$q->add_header(-cookie => 'foobar');

{
    my $header = $q->header(-type => 'text/html');
    like $header, qr/Set-Cookie: foobar/, 'cookie';
}

$q->add_header(-pragma => 'No-Cache');


{
    my $header = $q->header(-type => 'text/html');
    like $header, qr/Set-Cookie: foobar/, 'cookie';
    like $header, qr/Pragma: No-Cache/, 'pragma';
}


