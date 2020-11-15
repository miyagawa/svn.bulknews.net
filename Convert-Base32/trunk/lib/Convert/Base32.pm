package Convert::Base32;

use strict;
use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(encode_base32 decode_base32);
    
    $VERSION = '0.02';
}

use Carp ();

my %bits2char = qw@
00000 a
00001 b
00010 c
00011 d
00100 e
00101 f
00110 g
00111 h
01000 i
01001 j
01010 k
01011 l
01100 m
01101 n
01110 o
01111 p
10000 q
10001 r
10010 s
10011 t
10100 u
10101 v
10110 w
10111 x
11000 y
11001 z	
11010 2
11011 3
11100 4
11101 5
11110 6
11111 7
    @; # End of qw

my %char2bits = reverse %bits2char;

sub encode_base32($) {
    my $str = shift;

    my $stream_bits = '';
    my $res = '';

    for my $pos (0 .. length($str)-1) {
	$stream_bits .= unpack('B*',substr($str,$pos,1));
    }
    
    # If the input stream is not an even multiple of 5 bits,
    # pad the input stream with 0 bits
    if (my $remainder = length($stream_bits) % 5) {
	$stream_bits .= '0' x (5 - $remainder);
    }

    while ($stream_bits =~ m/(.{5})/g) {
	$res .= $bits2char{$1};
    }

    return $res;
}

sub decode_base32($) {
    my $str = shift;

    # non-base32 chars
    if ($str =~ tr/a-z2-7//c) {
        Carp::croak('Data contains non-base32 characters');
    }

    my $input_check = length($str) %8;
    if ($input_check == 1 || $input_check == 3 || $input_check == 8) {
	Carp::croak('Length of data invalid');
    }
    
    my $buffer = '';
    for my $pos (0..length($str)-1) {
	$buffer .= $char2bits{substr($str, $pos, 1)};
    }

    my $padding = length($buffer) % 8;
    $buffer =~ s/0{$padding}$// or Carp::croak('PADDING number of bits at the end of output buffer are not all zero');

    return pack('B*', $buffer);
}


1;
__END__

=head1 NAME

Convert::Base32 - Encoding and decoding of base32 strings

=head1 SYNOPSIS

  use Convert::Base32;

  $encoded = encode_base32("\x3a\x27\x0f\x93");
  $decoded = decode_base32($encoded);


=head1 DESCRIPTION

This module provides functions to convert string from / to Base32
encoding, specified in RACE internet-draft. The Base32 encoding is
designed to encode non-ASCII characters in DNS-compatible host name
parts.

See http://www.ietf.org/internet-drafts/draft-ietf-idn-race-03.txt for
more details.

=head1 FUNCTIONS

Following functions are provided; like C<MIME::Base64>, they are in
B<@EXPORT> array. See L<Exporter> for details.

=over 4 

=item encode_base32($str)

Encode data by calling the encode_base32() function. This function
takes a string to encode and returns the encoded base32 string.

=item decode_base32($str)

Decode a base32 string by calling the decode_base32() function. This
function takes a string to decode and returns the decoded string.

This function might throw the exceptions such as "Data contains
non-base32 characters", "Length of data invalid" and "PADDING number
of bits at the end of output buffer are not all zero".

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@bulknews.net>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

http://www.ietf.org/internet-drafts/draft-ietf-idn-race-03.txt, L<MIME::Base64>, L<Convert::RACE>.

=cut
