use strict;
use Test::More tests => 3;

use Error;

@MyException::ISA = qw(Error::Simple);
@AnotherException::ISA = qw(MyException);
@YetAnotherException::ISA = qw(AnotherException);

use Exception::Handler
    MyException => \&my_handler,
    AnotherException => \&another_handler,
    __DEFAULT__ => \&default_handler;

eval { throw MyException 'foo' };
eval { throw AnotherException 'foo'; };
eval { throw YetAnotherException 'foo'; };

sub my_handler {
    isa_ok $_[0], 'MyException';
}

sub another_handler {
    isa_ok $_[0], 'AnotherException';
}

sub default_handler {
    isa_ok $_[0], 'YetAnotherException';
}





