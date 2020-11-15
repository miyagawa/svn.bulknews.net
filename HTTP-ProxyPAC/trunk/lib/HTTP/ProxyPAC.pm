package HTTP::ProxyPAC;

use strict;
our $VERSION = '0.01';

use Carp;
use JavaScript;
use Scalar::Util qw(blessed);
use URI;

use HTTP::ProxyPAC::Functions;
use HTTP::ProxyPAC::Result;

our $UserAgent;

sub new {
    my($class, $stuff) = @_;

    if (blessed($stuff) && $stuff->isa('URI')) {
        return $class->init( $class->load_uri($stuff) );
    }
    elsif (blessed($stuff) && $stuff->isa('IO::Handle')) {
        return $class->init( $class->load_fh($stuff) );
    }
    elsif (ref($stuff) && ref($stuff) eq 'GLOB') {
        return $class->init( $class->load_fh($stuff) );
    }
    elsif (ref($stuff) && ref($stuff) eq 'SCALAR') {
        return $class->init( $$stuff );
    }
    elsif (!ref($stuff)) {
        return $class->init( $class->load_file($stuff) );
    }
    else {
        Carp::croak("Unknown reference type to HTTP::ProxyPAC->new: ", ref($stuff));
    }
}

sub load_uri {
    my($class, $uri) = @_;

    $UserAgent ||= do {
        require LWP::UserAgent;
        LWP::UserAgent->new(agent => __PACKAGE__ . "/" . $VERSION);
    };

    my $res = $UserAgent->get($uri);

    if ($res->content_type ne "application/x-ns-proxy-autoconfig") {
        Carp::croak("Content-Type should be application/x-ns-proxy-autoconfig, but ", $res->content_type);
    }

    return $res->content;
}

sub load_fh {
    my($class, $fh) = @_;
    read($fh, my($body), -s $fh);
    $body;
}

sub load_file {
    my($class, $file) = @_;

    open my $fh, $file or Carp::croak("$file: $!");
    my $body = $class->load_fh($fh);
    close $fh;

    $body;
}


sub init {
    my($class, $code) = @_;

    my $runtime = JavaScript::Runtime->new;
    my $context = $runtime->create_context();

    for my $func (@HTTP::ProxyPAC::Functions::PACFunctions) {
        no strict 'refs';
        $context->bind_function( name => $func, func => sub { &{"HTTP::ProxyPAC::Functions::$func"}(@_) });
    }

    $context->eval($code);

    bless { context => $context }, $class;
}

sub find_proxy {
    my($self, $url) = @_;

    Carp::croak("Usage: find_proxy(url)") unless defined $url;

    $url = URI->new($url);

    my $res = $self->{context}->eval( sprintf("FindProxyForURL('%s', '%s')", $url->as_string, $url->host) );

    my @res = HTTP::ProxyPAC::Result->parse($res, $url);
    return wantarray ? @res : $res[0];
}

1;
__END__

=head1 NAME

HTTP::ProxyPAC - parse PAC (Proxy Auto Config) files

=head1 SYNOPSIS

  use HTTP::ProxyPAC;

  my $pac = HTTP::ProxyPAC->new( URI->new("http://www.example.com/proxy.pac") );
  my $res = $pac->find_proxy("http://www.google.com/");

  if ($res->direct) {
      ...
  } elsif ($res->proxy) {
      $ua->proxy('http' => $res->proxy);
  }

=head1 DESCRIPTION

HTTP::ProxyPAC is a plugin to parse Proxy Auto Configuration file to
find appropriate proxy for any URL. You can share the same proxy setup
by using the same I<proxy.pac> file as your favorite browsers like
Firefox, IE or Opera.

=head1 METHODS

=over 4

=item new

  HTTP::ProxyPAC->new(URI->new("http://example.com/proxy.pac"));
  HTTP::ProxyPAC->new("/path/to/proxy.pac");
  HTTP::ProxyPAC->new(\$content);
  HTTP::ProxyPAC->new($fh);

Creates new HTTP::ProxyPAC object. It accepts arguments such as URI
object, path to the proxy.pac file, scalar reference to the JavaScript
code, filehandle or IO::Handle object.

=item find_proxy

  $res = $pac->find_proxy($url);
  @res = $pac->find_proxy($url);

Wrapper method for the JavaScript I<FindProxyForURL> function. Takes
URL as string or URI object and returns HTTP::ProxyPAC::Result object.

I<FindProxyForURL> function might return multiple candidates. In that
case, I<find_proxy> will return Result objects as arrray in an array
context, and only the first result in a scalar context.

=cut

=head1 WHAT ABOUT HTTP::ProxyAutoConfig?

I know that there's already HTTP::ProxyAutoConfig module that exactly
does the same thing, and actually this module reuses lots of PAC
functions defined there (Thanks!).

The reason why I wrote this module is, Javascript2Perl converter
function defined in HTTP::ProxyAutoConfig looks horrible, and actually
the generated perl code doesn't compile for me. So I created yet
another module of mine that uses SpiderMonkey based JavaScript
binding, which might be overkill for this task, but should definitely
be more robust.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

Ryan Eatmon wrote PAC functions in Perl for HTTP::ProxyAutoConfig,
where I copied all the HTTP::ProxyPac::Functions from.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::ProxyAutoConfig>, L<JavaScript>, L<http://wp.netscape.com/eng/mozilla/2.0/relnotes/demo/proxy-live.html>

=cut
