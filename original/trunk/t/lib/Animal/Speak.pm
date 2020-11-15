package Animal::Speak;
use strict;
use original 'Animal';

sub speak {
    my $self = shift;
    return "My name is $self->{name}";
}

1;
