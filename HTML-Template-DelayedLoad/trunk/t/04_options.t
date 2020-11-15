use strict;
use Test::More tests => 2;

use HTML::Template::DelayedLoad;

{
    my $tmpl = HTML::Template::DelayedLoad->new(die_on_bad_params => 0);
    $tmpl->param(foo => 'bar');
    $tmpl->param(foolist => [ { bar => 'baz' } ]);
    
    $tmpl->load(filename => './t/test1.html');
    is $tmpl->output, "bar\n", 'output';
}

{
    my $tmpl = HTML::Template::DelayedLoad->new(die_on_bad_params => 1);
    $tmpl->param(foo => 'bar');
    $tmpl->param(foolist => [ { bar => 'baz' } ]);

    eval {
	$tmpl->load(filename => './t/test1.html');
	$tmpl->output;
    };
    ok $@, $@;
}


