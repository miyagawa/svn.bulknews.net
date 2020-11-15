use strict;
use Test::More;
use WebService::LivedoorReader;

unless ($ENV{LIVEDOOR_ID}) {
    plan skip_all => "no LIVEDOOR_ID";
}

plan 'no_plan';

my $reader = WebService::LivedoorReader->new(
    username => $ENV{LIVEDOOR_ID},
    password => $ENV{LIVEDOOR_PASSWORD},
);

ok $reader->login;

