use strict;
use Test::More tests => 22;

use Mail::Address::Classify;

my @ok = (
    'foo@docomo.ne.jp',
    'foo@mnx.ne.jp',
    'foo@bar.mnx.ne.jp',
    'foo@ezweb.ne.jp',
    'foo@hoge.ezweb.ne.jp',
    'foo@dct.dion.ne.jp',
    'foo@ez1.ido.ne.jp',
    'foo@cmail.ido.ne.jp',
    'foo@jp-d.ne.jp',
    'foo@sky.tu-ka.ne.jp',
    'foo@bar.sky.tkc.ne.jp',
    'foo@em.nttpnet.ne.jp',
    'foo@bar.em.nttpnet.ne.jp',
    'foo@pdx.ne.jp',
    'foo@dx.pdx.ne.jp',
    'foo@phone.ne.jp',
    'foo@bar.mozio.ne.jp',
    'foo@p1.foomoon.com',
    'foo <foo@p1.foomoon.com>',
);

my @not = (
    'foo@example.com',
    'foo@dxx.pdx.ne.jp',
    'barabr',
);

for my $ok (@ok) {
    my $addr = Mail::Address::Classify->new($ok);
    ok $addr->belongs('mobile_jp'), $ok;
}

for my $not (@not) {
    my $addr = Mail::Address::Classify->new($not);
    ok ! $addr->belongs('mobile_jp'), $not;
}



