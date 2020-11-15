package Net::DNS::IgnoreVerisign;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use Net::DNS::Resolver;

local $^W;
my $old = Net::DNS::Resolver::Base->can('query');
*Net::DNS::Resolver::Base::query = sub {
    my $self = shift;
    my $ans  = $self->$old(@_);
    if ($ans && $ans->{answer}->[0]->{address} eq '64.94.110.11') {
	return;
    }
    return $ans;
};

1;
__END__

=head1 NAME

Net::DNS::IgnoreVerisign - fix Net::DNS to ignore Verisign's SiteFinder service

=head1 SYNOPSIS

  use Net::DNS;
  use Net::DNS::IgnoreVerisign;

  my $res = Net::DNS::Resolver->new();
  my $ans = $res->search("domain-which-is-not-existent.com");

=head1 DESCRIPTION

Net::DNS::IgnoreVerisign is a Net::DNS fixer to ignore Verisign
Sitefinder stuff. This module globally overrides Net::DNS::Resolver's
C<query> method. So it's not a perfect solution, but it'd be enough
for a usual Net::DNS users in perl API layer.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::DNS>

http://achurch.org/bind-verisign-patch.html

=cut
