use strict;
use utf8;
use Test::More 'no_plan';
use Encode;
use Encode::JP::Mobile;

sub test_rt {
    my ($name, $x, $y) = @_;

    is encode($x->{enc}, decode($y->{enc}, $y->{bytes})), $x->{bytes}, $name;
    is encode($y->{enc}, decode($x->{enc}, $x->{bytes})), $y->{bytes}, $name;
}

test_rt(
    'i2e',
    { enc => "shift_jis-imode", bytes => "\xF8\xA4" },
    {
        enc   => 'shift_jis-kddi',
        bytes => "\xF6\x41"
    },
);

test_rt(
    'i2e',
    { enc => "shift_jis-imode", bytes => "\xF8\xA4" },
    {
        enc   => 'shift_jis-imode',
        bytes => "\xF8\xA4"
    },
);
