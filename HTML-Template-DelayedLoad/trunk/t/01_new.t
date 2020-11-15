use strict;
use Test::More tests => 2;

use HTML::Template::DelayedLoad;

my $tmpl = HTML::Template::DelayedLoad->new;
ok $tmpl->isa('HTML::Template::DelayedLoad'), 'new() succeeds';
ok $tmpl->param(foo => 'bar'), 'can param';

