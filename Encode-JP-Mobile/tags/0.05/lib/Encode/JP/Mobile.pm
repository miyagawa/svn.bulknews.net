package Encode::JP::Mobile;
our $VERSION = "0.05";

use Encode;
use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

use Encode::Alias;
define_alias('shift_jis-docomo' => 'shift_jis-imode');
define_alias('shift_jis-ezweb' => 'shift_jis-kddi');
define_alias('shift_jis-airh' => 'shift_jis-airedge');

use Encode::JP::Mobile::Vodafone;

1;
__END__

=head1 NAME

Encode::JP::Mobile - Shift_JIS variants of Japanese Mobile phones

=head1 SYNOPSIS

  use Encode::JP::Mobile;

  my $char   = "\x82\xb1\xf9\x5d\xf8\xa0\x82\xb1";
  my $string = decode("shift_jis-imode", $char);

=head1 DESCRIPTION

Encode::JP::Mobile is an Encode module to support Shift_JIS variants used in Japaese mobile phone browsers.

This module is B<EXPERIMENTAL>. That means API and implementations will sometimge be backward incompatible.

=head1 ENCODINGS

This module currently supports the following encodings.

=over 4

=item shift_jis-imode

for DoCoMo pictograms. C<shift_jis-docomo> is alias.

=item shift_jis-vodafone

for Vodafone pictograms. Since it uses escape sequence, decoding algorithm is not based on ucm file.

=item shift_jis-kddi

for KDDI/AU pictograms. C<shift_jis-ezweb> is alias.

=item shift_jis-airedge

for AirEDGE pictograms. C<shift_jis-airh> is alias.

=back

=head1 NOTES

=over 4

=item *

ucm files are based on C<cp932.ucm>, not C<shiftjis.ucm>, since it
looks more appropriate for possible use cases. I'm open for any
suggesitions on this matter.

=item *

Pictogram characters are defined to be round-trip safe. However, they
use Unicode Private Area for such characters, that means you'll have
interoperability issues, which this module doesn't try yet to solve
completely.

=item *

As of version 0.04, this module tries to do auto-conversion of KDDI/AU
and NTT-DoCoMo pictogram characters. Supporting Softbank characters
are still left TODO.

=back

=head1 TODO

=over 4

=item *

Support KDDI encodings for 7bit E-mail (C<iso-2022-jp-kddi>).

=item *

Implement all merged C<shift_jis-mobile-jp> encoding.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software, licensed under the same terms with Perl.

=head1 SEE ALSO

L<Encode>, L<HTML::Entities::ImodePictogram>

http://www.nttdocomo.co.jp/p_s/imode/make/emoji/
http://www.au.kddi.com/ezfactory/tec/spec/3.html
http://developers.vodafone.jp/dp/tool_dl/web/picword_top.php
http://www.willcom-inc.com/p_s/products/airh_phone/homepage.html

=cut
