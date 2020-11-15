package original;

use strict;
use vars qw($VERSION);
$VERSION = 0.02;

use Devel::Symdump;

my %Registered;

sub import {
    my($class, $orig) = @_;
    my $pkg = caller;

    no strict 'refs';
    *{"$pkg\::import"} = sub {
	return if exists $Registered{$pkg};
	local $^W = 0;
	for my $method (__find_methods($pkg)) {
	    next if $method eq 'import';
	    if (defined &{"$orig\::$method"}) {
		$Registered{$pkg}{$method} = \&{"$orig\::$method"};
	    }
	    *{"$orig\::$method"} = \&{"$pkg\::$method"};
	}
    };
    *{"$pkg\::original"} = \&original;
}

sub __find_methods {
    my $pkg = shift;
    return map { s/^$pkg\:://; $_ } Devel::Symdump->functions($pkg);
}

sub original {
    (my $meth = (caller(1))[3]) =~ s/.*:://;
    no strict 'refs';
    goto &{"ORIGINAL::$meth"};
}

package ORIGINAL;
use vars qw($AUTOLOAD);

sub AUTOLOAD {
    my $pkg = caller;
    (my $meth = $AUTOLOAD) =~ s/.*:://;
    my $orig = $Registered{$pkg}{$meth};
    goto &$orig;
}

1;
__END__

=head1 NAME

original - MixJuice in Perl

=head1 SYNOPSIS

  package Animal;
  sub new {
      my($class, $hashref) = @_;
      bless {%$hashref}, $class;
  }

  package Animal::Speak;
  use original 'Animal';

  sub speak {
      my $self = shift;
      return "My name is $self->{name}";
  }

  package Animal::Dog;
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
      # or $self->original(@_);
  }

  # Then, in a main script!
  use Animal;
  use Animal::Speak;

  my $spot = Animal->new({ name => 'Spot' });
  print $spot->speak;  # 'My name is Spot';

  use Animal::Dog;
  my $snoopy = Animal->new({ name => 'Snoopy' });
  print $snoopy->bark;  # 'bow wow';
  print $snoopy->speak; # 'Snoopy is Snoopy';

=head1 DESCRIPTION

original.pm is a proof-of-concept implemetation of MixJuice, in
Perl. See http://staff.aist.go.jp/y-ichisugi/mj/ for details :)

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://www.ogis-ri.co.jp/otc/hiroba/technical/MixJuice/, L<NEXT>,
L<Exporter::Lite>, L<Class::Virtually::Abstract>

=cut

