use strict;
use Test::More tests => 14;

use WWW::Baseball::NPB;

{
    local $^W = 0;
    *LWP::Simple::get = sub ($) {
	local $/;
	require FileHandle;
	my $handle = FileHandle->new("t/20020331-pre.html");
	return <$handle>;
    };
}

my $baseball = WWW::Baseball::NPB->new;

{
    my @games = $baseball->games;
    is @games, 6;

    isa_ok $_, 'WWW::Baseball::NPB::Game' for @games;

    my $game = $games[0];
    is $game->league, 'central';
    is $game->home, '���';
    is $game->visitor, '���';
    is $game->score('���'), '';
    is $game->score('���'), '';
    is $game->status, '18��00ʬ';
    is $game->stadium, '����ɡ���';
}



