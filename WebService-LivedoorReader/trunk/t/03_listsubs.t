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

my $subs = $reader->listsubs({ unread => 1 });
ok $subs->[0]->{subscribe_id};

my $feed = $reader->unread($subs->[0]->{subscribe_id});
ok $feed->{channel}->{title};

ok $feed->{items}->[0]->{title};

