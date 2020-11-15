use strict;
use Test::More tests => 1;

use CGI;
use CGI::BufferedHeader;

my $q = CGI::BufferedHeader->new(CGI->new);
$q->param(foo => 'bar');
is $q->param('foo'), 'bar', 'param works';


