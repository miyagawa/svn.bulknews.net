package Three::AddThree;
use strict;
use original 'Three';

sub value {
    my $class = shift;
    $class->original + 3;
}

1;
