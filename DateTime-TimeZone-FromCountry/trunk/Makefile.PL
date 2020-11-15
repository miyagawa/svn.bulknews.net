use inc::Module::Install;
name 'DateTime-TimeZone-FromCountry';
all_from 'lib/DateTime/TimeZone/FromCountry.pm';

requires 'DateTime';
requires 'DateTime::TimeZone', '0.50';
requires 'Locale::Country';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
