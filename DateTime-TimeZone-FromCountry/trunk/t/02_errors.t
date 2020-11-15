use strict;
use Test::Base;
use DateTime::TimeZone::FromCountry;

filters { input => 'chomp', expected => 'regexp' };

plan tests => 1 * blocks;
run {
    my $block = shift;
    eval { DateTime::TimeZone->from_country($block->input) };
    like $@, $block->expected, $block->name;
};

__END__

=== Unknown country code
--- input
XX
--- expected
Unknown country code: XX

=== Unknown full country name
--- input
Foo Bar
--- expected
Unknown country name: Foo Bar

=== undef
--- input eval
undef
--- expected
Country code is required
