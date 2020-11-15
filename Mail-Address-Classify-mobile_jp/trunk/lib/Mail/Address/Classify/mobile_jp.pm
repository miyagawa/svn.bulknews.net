package Mail::Address::Classify::mobile_jp;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

# This regex is generated using http://www.mag2.com/faq/mobile.htm

my $regex = qr@^(?:
docomo\.ne\.jp|
mnx\.ne\.jp|
.*\.mnx\.ne\.jp|
ezweb\.ne\.jp|
.*\.ezweb\.ne\.jp|
dct\.dion\.ne\.jp|
tct\.dion\.ne\.jp|
hct\.dion\.ne\.jp|
kct\.dion\.ne\.jp|
cct\.dion\.ne\.jp|
sct\.dion\.ne\.jp|
qct\.dion\.ne\.jp|
oct\.dion\.ne\.jp|
ez.\.ido\.ne\.jp|
cmail\.ido\.ne\.jp|
email\.sky\.tdp\.ne\.jp|
email\.sky\.kdp\.ne\.jp|
email\.sky\.cdp\.ne\.jp|
jp\-d\.ne\.jp|
jp\-h\.ne\.jp|
jp\-t\.ne\.jp|
jp\-c\.ne\.jp|
jp\-r\.ne\.jp|
jp\-k\.ne\.jp|
jp\-n\.ne\.jp|
jp\-s\.ne\.jp|
jp\-q\.ne\.jp|
sky\.tu\-ka\.ne\.jp|
cara\.tu\-ka\.ne\.jp|
sky\.tkk\.ne\.jp|
.*\.sky\.tkk\.ne\.jp|
sky\.tkc\.ne\.jp|
.*\.sky\.tkc\.ne\.jp|
email\.sky\.dtg\.ne\.jp|
em\.nttpnet\.ne\.jp|
.*\.em\.nttpnet\.ne\.jp|
cmchuo\.nttpnet\.ne\.jp|
cmhokkaido\.nttpnet\.ne\.jp|
cmtohoku\.nttpnet\.ne\.jp|
cmtokai\.nttpnet\.ne\.jp|
cmkansai\.nttpnet\.ne\.jp|
cmchugoku\.nttpnet\.ne\.jp|
cmshikoku\.nttpnet\.ne\.jp|
cmkyusyu\.nttpnet\.ne\.jp|
pdx\.ne\.jp|
d.\.pdx\.ne\.jp|
phone\.ne\.jp|
.*\.mozio\.ne\.jp|
page\.docomonet\.or\.jp|
page\.ttm\.ne\.jp|
pho\.ne\.jp|
moco\.ne\.jp|
emcm\.ne\.jp|
p1\.foomoon\.com
)$@x; # end of qr@@

sub is_valid {
    my($class, $addr) = @_;
    my $domain = $addr->host;
    return $domain && $domain =~ m/$regex/o;
}

1;
__END__

=head1 NAME

Mail::Address::Classify::mobile_jp - classificatin for mobile mail in Japan

=head1 SYNOPSIS

  use Mail::Address::Classify;

  my $addr = Mail::Address::Classify->new('fooooooo@docomo.ne.jp')
  if ($addr->belongs('mobile_jp')) { }

=head1 DESCRIPTION

Mail::Address::Classify::mobile_jp is a plugin module for
Mail::Address::Classify, which validates whether an address belongs to
mobile mail address in Japan or not.

This module should be updated heavily :)

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mail::Address::Classify>, http://www.mag2.com/faq/mobile.htm

=cut
