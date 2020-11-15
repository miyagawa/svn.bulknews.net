use strict;
use Test::More tests => 3;

use Apache::Session::Generate::ModUsertrack;

my $session = bless { data => {}, args => {} }, 'Apache::Session';
eval  {
    Apache::Session::Generate::ModUsertrack::generate($session);
};

like $@, qr/usertrack/, 'fails to load cookie';

my $id = '127.0.0.1.00000000000000000';
{
    local $ENV{COOKIE} = "Apache=$id";
    Apache::Session::Generate::ModUsertrack::generate($session);
    is $session->{data}->{_session_id}, $id, 'fetch cookie';
}

{
    local $ENV{COOKIE} = "foobar=$id";
    $session->{args}->{ModUsertrackCookieName} = 'foobar';
    Apache::Session::Generate::ModUsertrack::generate($session);
    is $session->{data}->{_session_id}, $id, 'fetch cookie in another name';
}






