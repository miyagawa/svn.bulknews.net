use strict;
use Test::More tests => 5;

use Exception::Handler
    MyException => \&my_handler,
    AnotherException => \&another_handler,
    __DEFAULT__ => \&default_handler;

eval { die bless {}, 'MyException'; };
eval { die bless {}, 'AnotherException'; };
eval { die bless {}, 'YetAnotherException'; };
eval { die "foo"; };

sub my_handler {
    isa_ok $_[0], 'MyException';
}

sub another_handler {
    isa_ok $_[0], 'AnotherException';
}

sub default_handler {
    if (ref $_[0]) {
	isa_ok $_[0], 'YetAnotherException';
    }
    else {
	like $_[0], qr/foo/;
    }
}

package Foo;
use Exception::Handler;

eval { die "foo" };



