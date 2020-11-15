use strict;
use Test::More tests => 2;

use Exception::Handler
    MyException => \&my_handler;

eval { die bless {}, 'MyException' };
eval { die bless {}, 'AnotherException' };

isa_ok $@, 'AnotherException';

sub my_handler {
    isa_ok $_[0], 'MyException';
}





