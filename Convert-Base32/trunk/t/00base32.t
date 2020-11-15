use strict;
use Test;
BEGIN { plan tests => 4 }

use Convert::Base32 qw(encode_base32 decode_base32);

my $str1 = "\x3a\x27\x0f\x93";
my $str2 = "\x3a\x27\x0f\x93\x2a";

my $enc1 = 'hitq7ey';
my $enc2 = 'hitq7ezk';

ok(encode_base32($str1), $enc1);
ok(encode_base32($str2), $enc2);

ok(decode_base32($enc1), $str1);
ok(decode_base32($enc2), $str2);
