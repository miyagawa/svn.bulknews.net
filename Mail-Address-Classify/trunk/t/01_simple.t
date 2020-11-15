use strict;
use Test::More tests => 8;

use Mail::Address::Classify;

package Mail::Address::Classify::foo;

sub is_valid {
    my($class, $addr) = @_;
    return 1;
}

package Mail::Address::Classify::bar;

sub is_valid {
    my($class, $addr) = @_;
    return 0;
}

package main;
{
    my $addr = Mail::Address::Classify->new('foo@foo.com');
    ok $addr, 'can make instance';
    is $addr->address, 'foo@foo.com', 'address() method';

    ok $addr->belongs('foo'), 'foo';
    ok ! $addr->belongs('bar'), 'bar';
}

{
    my $addr = Mail::Address::Classify->new(
	Mail::Address->new(
	    'foo', 'foo@foo.com',
	),
    );
    ok $addr, 'can make instance';
    is $addr->address, 'foo@foo.com', 'address() method';

    ok $addr->belongs('foo'), 'foo';
    ok ! $addr->belongs('bar'), 'bar';
}

