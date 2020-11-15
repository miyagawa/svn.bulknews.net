package MIME::WordDecoder::Japanese;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use base qw(MIME::WordDecoder);

use Jcode;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new;
    $self->handler(
	'ISO-2022-JP' => $self->decode_sub('jis'),
	'SHIFT_JIS'   => $self->decode_sub('sjis'),
	'EUC-JP'      => $self->decode_sub('euc'),
    );
    $self->{MWDJ_decode_charset} = 'euc';
    $self;
}

sub decode_charset {
    my $self = shift;
    if (@_) {
	my $charset = shift;
	unless (Jcode->can($charset)) {
	    require Carp;
	    Carp::croak "invalid charset $charset for MIME::WordDecoder::Japanese";
	}
	$self->{MWDJ_decode_charset} = $charset;
    }
    $self->{MWDJ_decode_charset};
}

sub decode_sub {
    my($self, $code) = @_;
    return sub {
	my($data, $charset, $decoder) = @_;
	my $outcode = $decoder->{MWDJ_decode_charset};
	return Jcode->new(\$data, $code)->$outcode();
    };
}

# install myself
for (qw(iso-2022-jp shift_jis euc-jp)) {
    MIME::WordDecoder->supported($_ => __PACKAGE__->new);
}
MIME::WordDecoder->default(__PACKAGE__->new);

1;
__END__

=head1 NAME

MIME::WordDecoder::Japanese - Japanese MIME decoder

=head1 SYNOPSIS

  use MIME::WordDecoder::Japanese;

  $wd = MIME::WordDecoder::Japanese->new;
  # or
  $wd = MIME::WordDeocder->supported('iso-2022-jp');
  $str = $wd->decode('=?ISO-2022-JP?B?GyRCJCIkJCQmJCgkKhsoQg==?=');

=head1 DESCRIPTION

MIME::WordDeocder::Japanese is a glue between MIME::WordDecoder and
Jcode. This decoder supports MIME decoding between each combination of
two from C<iso-2022-jp>, C<shift_jis> and C<euc-jp>.

=head1 METHODS

=over 4

=item decode_charset

  $wd->decode_charset([ CHARSET ]);

get/set charset for decoding. Charset should be the method name of
Jcode. Default is C<euc>.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@bulknews.net>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<MIME::WordDecoder>, L<Jcode>

=cut
