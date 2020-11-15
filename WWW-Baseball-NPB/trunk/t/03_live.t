use strict;
use Test::More tests => 14;

use WWW::Baseball::NPB;

{
    local $^W = 0;
    *LWP::Simple::get = sub ($) {
	local $/;
	require FileHandle;
	my $handle = FileHandle->new("t/20020331-live.html");
	return <$handle>;
    };
}

my $baseball = WWW::Baseball::NPB->new;

{
    my @games = $baseball->games;
    is @games, 6;

    isa_ok $_, 'WWW::Baseball::NPB::Game' for @games;

    my $game = $games[3];
    is $game->league, 'pacific';
    is $game->home, '��Ŵ';
    is $game->visitor, '����å���';
    is $game->score('��Ŵ'), 0;
    is $game->score('����å���'), 0;
    is $game->status, '1��΢';
    is $game->stadium, '���ɡ���';
}



