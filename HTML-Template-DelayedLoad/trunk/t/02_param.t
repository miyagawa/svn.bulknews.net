use strict;
use Test::More tests => 3;

use HTML::Template::DelayedLoad;

my $tmpl = HTML::Template::DelayedLoad->new;
$tmpl->param(foo => 'bar');
is $tmpl->param('foo'), 'bar', 'param() with one argument';

$tmpl->param(foolist => [ { bar => 'baz' } ]);
ok eq_array($tmpl->param('foolist'), [ { bar => 'baz' } ]), 'arrayref';

ok eq_array([ sort $tmpl->param() ], [ sort 'foo', 'foolist' ]), 'param()';

