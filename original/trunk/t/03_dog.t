use strict;
use Test::More 'no_plan';

use lib 't/lib';

use Animal;
use Animal::Speak;
use Animal::Dog;

{
    my $dog = Animal->new({ name => 'Snoopy' });
    is $dog->bark, 'bow wow';
    is $dog->speak, 'Snoopy is Snoopy';
}

{
    my $dog = Animal->new({ name => 'Spot' });
    is $dog->bark, 'bow wow';
    is $dog->speak, 'My name is Spot';
}
