package CGI::BufferedHeader;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use CGI;
use Class::Delegation
    send => -ALL, to => '_query';

sub new {
    my($class, $query) = @_;
    bless {
	_header_buf => {},
	_query => $query,
    }, $class;
}

sub add_header {
    my($self, $key, $value) = @_;
    $self->{_header_buf}->{$key} = $value;
}

sub header_out {
    my($self, $key, $value) = @_;
    $key =~ s/-/_/g;
    $self->add_header("-$key" => $value);
}

sub header {
    my($self, @args) = @_;
    my $meth = sub {
	$self->{_query}->header(%{$self->{_header_buf}}, @args);
    };
    goto &$meth;		# caller sensitive
}

1;
__END__

=head1 NAME

CGI::BufferedHeader - Adds add_header method for CGI.pm

=head1 SYNOPSIS

  use CGI;
  use CGI::BufferedHeader;

  $query = CGI::BufferedHeader->new(CGI->new);
  $query->add_header(-cookie => $cookie);

  # later ...
  print $query->header(), $output;

=head1 DESCRIPTION

One of annoying feature of CGI.pm's header() method is that we should
pass all header variables to one header() call. This might be
bothersome like this:

  use CGI;
  use CGI::Cookie;

  $query = CGI->new;
  $cookie = CGI::Cookie->new(-name => 'sid', -value => $sid);

  # very later ...
  print $query->header(-cookie => $cookie);

Note that C<$cookie>'s scope is wide and its lifetime is long, which
also makes it difficult to extract these routine as a separate module
or so.

With CGI::BufferedHeader, you can do like this:

  use CGI;
  use CGI::BufferedHeader;
  use CGI::Cookie;

  $query = CGI::BufferedHeader->new(CGI->new);
  {
      $cookie = CGI::Cookie->new(-name => 'sid', -value => $sid);
      $query->add_header(-cookie => $cookie);
  }

  # very later ...
  print $query->header();

=head1 METHODS

=over 4

=item add_header()

  $query->add_header(-cookie => $cookie);

Buffers header parameters, and later passes them in header() method call.

=item header_out()

  $query->header_out(Cookie => $cookie);

Does similar to add_header(), other than its key does not start with '-'.

=back

=head1 CAVEAT

=over 4

=item *

Ordered style of parameters for header() is not supported, except
only single parameter.

  $query->header(-type => 'text/html'); # OK
  $query->header('text/html');          # OK
  $query->header('text/html', $cookie); # NG

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<CGI>, L<Class::Delegation>, L<Apache>

=cut
