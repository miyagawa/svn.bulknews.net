use strict;
use Test::More tests => 2;

package Test::L10N;
use base qw(Locale::Maketext);
use Locale::Maketext::Lexicon { en => [ Properties => 't/props.en' ] };

package main;

my $lh = Test::L10N->get_handle('en');
is $lh->maketext('email.invalid', 'foo@example.com'), 'Email foo@example.com is invalid';
is $lh->maketext('foo.bar'), 'baz';

