package DateTime::TimeZone::FromCountry;

use strict;
our $VERSION = '0.01';

use Carp;
use DateTime::TimeZone;
use DateTime::TimeZone::FromCountry::Zone qw($Map);

sub DateTime::TimeZone::from_country {
    my($class, $cc) = @_;

    defined $cc or croak "Country code is required";

    if ($cc !~ /^[A-Za-z]{2}$/) {
        eval { require Locale::Country };
        croak "Locale::Country is required to use full country names ($cc)" if $@;

        my $old = $cc;
        $cc = Locale::Country::country2code($cc)
            or croak "Unknown country name: $old";
    }

    my $tzs = $Map->{uc($cc)}
        or croak "Unknown country code: $cc";

    if (wantarray) {
        return map DateTime::TimeZone->new( name => $_ ), @$tzs;
    } else {
        return DateTime::TimeZone->new( name => $tzs->[0] );
    }
}

1;
__END__

=head1 NAME

DateTime::TimeZone::FromCountry - Create timezone(s) from country

=head1 SYNOPSIS

  use DateTime::TimeZone::FromCountry;

  my $time_zone = DateTime::TimeZone->from_country('JP');            # Asia/Tokyo
  my @time_zone = DateTime::TimeZone->from_country('US');            # List of possible TZs
  my $time_zone = DateTime::TimeZone->from_country('United States'); # America/New_York

=head1 DESCRIPTION

DateTime::TimeZone::FromCountry is a module to add an ability to
create DateTime::TimeZone object using country name.

=head1 METHODS

=over 4

=item from_country

  $time_zone = DateTime::TimeZone->from_country($country);
  @time_zone = DateTime::TimeZone->from_country($country);

Returns DateTime::TimeZone object for the country specified by
I<$country>. Country can be either ISO 3166 country code (I<JP>) or
full country name (I<Japan>). You'd need Locale::Country module to be
installed to use full country names.

In a list context it returns a list of possible timezones used in the
country, and in a scalar context it returns the first possible
timezone, which (1) makes some geographical sense, and (2) puts the
most populous zones first, where that does not contradict (1). (per
Olson database)

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

The actual country-code to Timezones data is generated using
I<zone.tab> file in the Olson database.

=head1 SEE ALSO

=cut
