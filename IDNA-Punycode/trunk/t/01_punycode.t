use strict;
use Test::More 'no_plan';

use FileHandle;
use IDNA::Punycode;

my @input = read_sample('t/sample.txt');

for (@input) {
    my($utf8, $punycode) = @$_;
    is encode_punycode($utf8), $punycode, "$punycode";
    is decode_punycode($punycode), $utf8, "$punycode";
}

sub read_sample {
    my $handle = FileHandle->new(shift);
    local $/ = '';
    my @input;
    while (my $block = <$handle>) {
	next if $block !~ /Punycode:/;
	my @unicode = $block =~ /u\+([0-9a-f]{4})/gi;
	my $punycode = ($block =~ /Punycode: (.+?)\n$/s)[0];
	push @input, [ join('', map chr(hex($_)), @unicode), $punycode ];
    }
    return @input;
}
