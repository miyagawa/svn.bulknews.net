use strict;
use Test::More tests => 2;

my $same = qx($^X htdiff t/foo.html t/bar.html);
is $same, '';

my $diff = qx($^X htdiff t/foo.html t/baz.html);
like $diff, qr/bar/;


