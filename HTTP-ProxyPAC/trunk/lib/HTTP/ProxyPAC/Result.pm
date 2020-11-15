package HTTP::ProxyPAC::Result;
use strict;
use Carp;

sub parse {
    my($class, $string, $url) = @_;
    my @res = split /;\s*/, $string;
    map $class->_parse($_, $url), @res;
}

sub _parse {
    my($class, $string, $url) = @_;

    $string =~ s/^(DIRECT|PROXY|SOCKS)\s*//
        or Carp::croak("Can't parse FindProxyForURL() return value: $string");

    my $self;
    $self->{type} = $1;

    if ($self->{type} ne 'DIRECT') {
        my $proxy = URI->new;
        $proxy->scheme($url->scheme); # same scheme as the target host
        $proxy->host_port($string);

        $self->{lc($self->{type})} = $proxy;
    }

    bless $self, $class;
}

sub direct { $_[0]->{type} eq 'DIRECT' }
sub proxy  { $_[0]->{proxy} }
sub socks  { $_[0]->{socks} }

1;

__END__

=head1 NAME

HTTP::ProxyPAC::Result - Result object for HTTP::ProxyPAC find_proxy

=head1 SYNOPSIS

  my $pac = HTTP::ProxyPAC->new($url);
  my $res = $pac->find_proxy('http://www.google.com/');

  $res->direct;
  $res->proxy;
  $res->socks;

=head1 DESCRIPTION

HTTP::ProxyPAC::Result is a class to encapsulate result object from find_proxy method.

=head1 METHODS

=over 4

=item direct

Boolean to indicate that the result is DIRECT or not.

=item proxy

URI object for the actual proxy server URL, if Result type is PROXY, otherwise undef.

=item socks

URI object for the actual socks server URL, if Result type is SOCKSn, otherwise undef.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<HTTP::ProxyPAC>

=cut
