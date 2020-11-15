package Animal;
use strict;

sub new {
    my($class, $hashref) = @_;
    bless {%$hashref}, $class;
}

1;
