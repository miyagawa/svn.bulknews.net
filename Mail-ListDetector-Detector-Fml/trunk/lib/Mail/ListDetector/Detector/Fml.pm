package Mail::ListDetector::Detector::Fml;

use strict;
use vars qw($VERSION);
$VERSION = '0.03';

use base qw(Mail::ListDetector::Detector::Base);
use URI;

BEGIN {
    # install me before RFC2369
    use Mail::ListDetector;
    @Mail::ListDetector::DETECTORS = map {
	$_ eq 'Mail::ListDetector::Detector::RFC2369'
	    ? (__PACKAGE__, $_) : $_;
    } @Mail::ListDetector::DETECTORS;
}

sub match {
    my($self, $message) = @_;
    my $head = $message->head;
    my $mlserver = $head->get('X-MLServer') or return;
    $mlserver =~ /^fml \[(fml [^\]]*)\]/ or return;

    # OK, this is FML message
    my $list = Mail::ListDetector::List->new;
    $list->listsoftware($1);

    chomp(my $post = $head->get('List-Post'));
    $list->posting_address(URI->new($post)->to);

    chomp(my $mlname = $head->get('X-ML-Name'));
    $list->listname($mlname);

    $list;
}

1;
__END__

=head1 NAME

Mail::ListDetector::Detector::Fml - FML message detector

=head1 SYNOPSIS

  use Mail::ListDetector::Detector::Fml;

=head1 DESCRIPTION

Mail::ListDetector::Detector::Fml is an implementation of a mailing
list detector, for FML. See http://www.fml.org/ for details about FML.

When used, this module installs itself to Mail::ListDetector. FML
maling list message is RFC2369 compliant, so can be matched with
RFC2369 detector, but this module allows you to parse more FML
specific information about the mailing list.

=head1 METHODS

=over 4

=item new, match

Inherited from L<Mail::ListDetector::Detector::Base>

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mail::ListDetector>

=cut
