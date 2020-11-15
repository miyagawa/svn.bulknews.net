package Locale::Maketext::Lexicon::Properties;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use Data::Properties;
use IO::ScalarArray;

sub parse {
    my $class = shift;
    my $props = Data::Properties->new;
    $props->load(IO::ScalarArray->new(\@_));
    my %data = map { $_ => scalar $props->get_property($_) } $props->property_names;
    return \%data;
}

1;
__END__

=head1 NAME

Locale::Maketext::Lexicon::Properties - Maketext plugin for Data::Properties

=head1 SYNOPSIS

  package Foo::L10N;
  use Locale::Maketext::Lexicon {
      en => [ 'Properties', 'properties.en' ],
  };

  package main;
  my $lh = Foo::L10N->get_handle('en');
  print $lh->maketext("email.invalid");

=head1 DESCRIPTION

Locale::Maketext::Lexicon::Properties is a plugin for
Locale::Maketext::Lexicon which parses C<java.util.Properties> file
using Data::Properties.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Locale::Maketext::Lexicon>, L<Data::Properties>

=cut
