use strict;
use Test::More tests => 1;

use HTML::Template::DelayedLoad;

my $tmpl = HTML::Template::DelayedLoad->new;
$tmpl->param(foo => 'bar');
$tmpl->param(foolist => [ { bar => 'baz' } ]);

$tmpl->load(filename => './t/test.html');
is $tmpl->output, "bar\nbaz\n", 'output';


