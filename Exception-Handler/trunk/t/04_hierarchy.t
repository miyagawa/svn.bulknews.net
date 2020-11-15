use strict;
use Test::More tests => 3;

use Exception::Class
    'MyException',
    'AnotherException' => { isa => 'MyException' },
    'YetAnotherException' => { isa => 'AnotherException' };

use Exception::Handler
    MyException => \&my_handler,
    AnotherException => \&another_handler,
    __DEFAULT__ => \&default_handler;

eval { MyException->throw; };
eval { AnotherException->throw; };
eval { YetAnotherException->throw; };

sub my_handler {
    isa_ok $_[0], 'MyException';
}

sub another_handler {
    isa_ok $_[0], 'AnotherException';
}

sub default_handler {
    fail 'no default';
}





