use strict;
use Test::Base;
use DateTime::TimeZone::FromCountry;

filters { input => 'chomp', expected => 'chomp' };

sub timezone {
    my $country = shift;
    my $tz = DateTime::TimeZone->from_country($country);
    return $tz->name;
}

sub timezone_multi {
    my $country = shift;
    my @tz = DateTime::TimeZone->from_country($country);
    return [ map $_->name, @tz ];
}

run_is_deeply 'input' => 'expected';

__END__

=== Simple one-to-one
--- input timezone
JP
--- expected
Asia/Tokyo

=== Multiple TZs: the first one
--- input timezone
US
--- expected
America/New_York

=== Case insensitive counry code
--- input timezone
tw
--- expected
Asia/Taipei

=== Full country names
--- input timezone
United States
--- expected
America/New_York

=== Multiple TZs
--- input timezone_multi
CN
--- expected lines chomp array
Asia/Shanghai
Asia/Harbin
Asia/Chongqing
Asia/Urumqi
Asia/Kashgar
