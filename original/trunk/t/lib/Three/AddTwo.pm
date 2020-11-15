package Three::AddTwo;
use strict;
use original 'Three';

sub value {
    my $class = shift;
    $class->ORIGINAL::value + 2;
}

1;
