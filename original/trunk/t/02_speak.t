use strict;
use Test::More 'no_plan';

use lib 't/lib';

use Animal;
use Animal::Speak;

{
    my $dog = Animal->new({ name => 'Snoopy' });
    is $dog->speak, 'My name is Snoopy';
}

{
    my $dog = Animal->new({ name => 'Spot' });
    is $dog->speak, 'My name is Spot';
}
