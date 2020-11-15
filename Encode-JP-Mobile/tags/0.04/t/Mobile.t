use strict;
use Test::More tests => 18;

use_ok('Encode');
use_ok('Encode::JP::Mobile');

test_rt("shift_jis-imode", "\x82\xb1\xf9\x5d\xf8\xa0\x82\xb1", "\x{3053}\x{e6b9}\x{e63f}\x{3053}");
test_rt("shift_jis-docomo", "\x82\xb1\xf9\x5d\xf8\xa0\x82\xb1", "\x{3053}\x{e6b9}\x{e63f}\x{3053}");
test_rt("shift_jis-kddi", "\x82\xb1\xF6\x59", "\x{3053}\x{e481}");
test_rt("shift_jis-ezweb", "\x82\xb1\xF6\x59", "\x{3053}\x{e481}");
test_rt("shift_jis-airedge", "\x82\xb1\xF0\x40", "\x{3053}\x{e000}");
test_rt("shift_jis-airh", "\x82\xb1\xF0\x40", "\x{3053}\x{e000}");
test_rt("shift_jis-vodafone", "\x82\xb1\x1b\x24\x47\x21\x22\x0f", "\x{3053}\x{e001}\x{e002}");
test_rt("shift_jis-softbank", "\x82\xb1\x1b\x24\x47\x21\x22\x0f", "\x{3053}\x{e001}\x{e002}");

sub test_rt {
    my ( $enc, $byte, $uni ) = @_;
    is esc( decode( $enc, $byte ) ), esc($uni), "decode $enc";
    is esc( encode( $enc, $uni ) ), esc($byte), "encode $enc";
}

sub esc {
    my $x = unpack( "H*", shift );
    $x =~ s/(..)/\\x$1/g;
    $x;
}
