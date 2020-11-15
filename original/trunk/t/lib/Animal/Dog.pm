package Animal::Dog;
use strict;
use original 'Animal';

sub bark {
    return 'bow wow';
}

sub speak {
    my $self = shift;
    if ($self->{name} eq 'Snoopy') {
	return "Snoopy is $self->{name}";
    }
    $self->ORIGINAL::speak(@_);
}

1;
