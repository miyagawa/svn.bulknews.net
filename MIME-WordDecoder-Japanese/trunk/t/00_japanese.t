use strict;
use Test::More tests => 10;

use Jcode;
use MIME::WordDecoder;
use MIME::WordDecoder::Japanese;

{
    ok(MIME::WordDecoder->supported('iso-2022-jp'), 'iso-2022-jp support');
    ok(MIME::WordDecoder->supported('shift_jis'), 'shift_jis support');
    ok(MIME::WordDecoder->supported('euc-jp'), 'euc-jp support');
}

{
    my $enc = '=?ISO-2022-JP?B?GyRCJCIkJCQmJCgkKhsoQg==?=';
    my $raw = 'あいうえお';

    my $wd = MIME::WordDecoder->default;
    is $wd->decode($enc), $raw, 'decoding';

    $wd->decode_charset('jis');
    is $wd->decode($enc), Jcode->new($raw)->jis, 'decode_charset';

    $wd->decode_charset('sjis');
    is $wd->decode($enc), Jcode->new($raw)->sjis, 'decode_charset';

    $wd->decode_charset('utf8');
    is $wd->decode($enc), Jcode->new($raw)->utf8, 'decode_charset';

    eval { $wd->decode_charset('xxx'); };
    like $@, qr/invalid charset xxx/, 'invalid charset';

    $wd->decode_charset('euc');	# XXX reset
}

{
    my $enc = '=?euc-jp?B?pKKkpKSmpKikqg==?=';
    my $raw = 'あいうえお';

    my $wd = MIME::WordDecoder->default;
    is $wd->decode($enc), $raw, 'decoding';
}

{
    my $enc = '=?shift_jis?B?gqCCooKkgqaCqA==?=';
    my $raw = 'あいうえお';

    my $wd = MIME::WordDecoder->default;
    is $wd->decode($enc), $raw, 'decoding';
}

