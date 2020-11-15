package Exception::Handler;

use strict;
use vars qw($VERSION %_Registered);
$VERSION = 0.01;

sub import {
    my $class = shift;
    my $pkg = caller(0);

    while (my($exception, $handler) = splice @_, 0, 2) {
	$_Registered{$pkg}{$exception} = $handler;
    }
    return unless exists $_Registered{$pkg};
    eval <<EVAL;
package $pkg;

\$SIG{__DIE__} = sub {
    my \$exception = shift;
    my \$handler = Exception::Handler->handler_for(__PACKAGE__, \$exception);
    \$handler ? \$handler->(\$exception) : die \$exception;
};
EVAL
    ;
}

sub handler_for {
    my($class, $pkg, $exception) = @_;
    my $exclass = ref $exception
	or return $_Registered{$pkg}{__DEFAULT__}; # exception is not an obj
    my $handler;
    no strict 'refs';
    while (defined $exclass && not defined $handler) {
	$handler = $_Registered{$pkg}{$exclass};
	my $isa = "$exclass\::ISA";
	last unless defined @$isa;
	$exclass = $isa->[0];
    }
    return $handler || $_Registered{$pkg}{__DEFAULT__};
}

1;
__END__

=head1 NAME

Exception::Handler - Hierarchical exception handling

=head1 SYNOPSIS

  use Exception::Class
      'MyException',
      'AnotherException' => { isa => 'MyException' },
      'YetAnotherException' => { isa => 'AnotherException' },
      'FooBarException';

  use Exception::Handler
      MyException => \&my_handler,
      AnotherException => \&another_handler,
      __DEFAULT__ => \&default_handler;

  eval { MyException->throw };	        # my_handler()
  eval { AnotherException->throw; };    # another_handler()
  eval { YetAnotherException->throw; };	# another_handler() : hierarchical
  eval { FooBarException->throw; };	# default_handler()

  sub my_handler {
      my $exception = shift;
      # ...
  }

  sub another_handler { }
  sub default_handler { }

=head1 DESCRIPTION

Exception::Handler allows you to handle exception with various subs
each of which registered for an appropriate class of exception. This
module can nicely work with Dave Rolsky's Exception::Class and Grahamm
Barr's Error module.

=head1 TODO

=over 4

=item *

Lexical handler, which maybe done via C<local>.

=cut

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Exception::Class>, L<Sig::PackageScoped>

=cut
