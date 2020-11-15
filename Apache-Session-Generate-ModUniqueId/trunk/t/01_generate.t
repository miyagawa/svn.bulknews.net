use strict;
use Test::More tests => 2;
use Apache::Session::Generate::ModUniqueId;

my $session = bless { data => {}, args => {} }, 'Apache::Session';
{
    eval  {
	Apache::Session::Generate::ModUniqueId::generate($session);
    };
    like $@, qr/mod_unique_id/, 'fails to load unique_id';
}

{
    local $ENV{UNIQUE_ID} = 'foobar';
    Apache::Session::Generate::ModUniqueId::generate($session);
    is $session->{data}->{_session_id}, 'foobar', 'unique id';
}
