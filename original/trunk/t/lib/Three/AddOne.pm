package Three::AddOne;
use strict;
use original 'Three';

sub value {
    my $class = shift;
    $class->ORIGINAL::value + 1;
}

1;
