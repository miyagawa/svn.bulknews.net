package Symbol::Approx::Sub::Google;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use SOAP::Lite;

use vars qw($LicenseKey);
$LicenseKey = undef;

sub match {
    my($sub, @subs) = @_;
    $LicenseKey or die "You need Google License Key to use this module.";

    my $match = SOAP::Lite
	->uri('urn:GoogleSearch')
	    ->proxy('http://api.google.com/search/beta2')
		->doSpellingSuggestion($LicenseKey, $sub)
		    ->result || $sub;

    return grep { $subs[$_] eq $match } 0..$#subs;
}

1;
__END__

=head1 NAME

Symbol::Approx::Sub::Google - uses Google Web API for approximate matching

=head1 SYNOPSIS

  use Symbol::Approx::Sub xform => undef, match => 'Google';

  $Symbol::Approx::Sub::Google::LicenseKey = "xxxxxxxxxxxxxx";

  sub perl { ... }
  perrl();			# corrected to perl()

=head1 DESCRIPTION

Symbol::Approx::Sub::Google is a plug-in for Symbol::Approx::Sub,
which allows you to use Google Web API's spell checking feature to
find approximate subroutine names.

This module would fail if you run your mis-spelled code more than 1000
times a day ;)

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Symbol::Approx::Sub>, http://www.google.com/apis/

=cut
