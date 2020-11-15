use strict;
use warnings;
use Test::More tests => 2;
use Encode;
use Encode::JP::Mobile;

{
    my $u = "\x{0647}";
    is encode("shift_jis-vodafone", $u, Encode::FB_HTMLCREF), "&#1607;";
}

{
    my $u = "\x{0647}";
    my $var = encode("shift_jis-vodafone", $u, sub { "x" . $_[0] });
    is $var, "x1607";
}


