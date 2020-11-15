use strict;
use Test::More tests => 1;

use lib 't/lib';

use Animal;

{
    my $dog = Animal->new({ name => 'Snoopy' });
    eval {
	$dog->bark;
    };
    like $@, qr/Can.t/;
}
