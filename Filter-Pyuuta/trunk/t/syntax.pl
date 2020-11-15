use strict;
use Filter::Pyuuta;

use vars qw(@res);		# elements: [ testname => 0, 1 ]

my $a = 0;

# if, elsif, else
もし ($a == 0) {
    push @res, [ 'if' => 1 ];
} もしくは ($a == 1) {
    push @res, [ 'elsif' => 0 ];
} ではない場合 {
    push @res, [ 'else' => 0 ];
}

# while, last
続ける (1) {
    push @res, [ 'while' => 1 ];
    抜ける;
}

# redo
{
    やり直し while ++$a == 2;
}

push @res, [ 'redo' => 1 ] if $a == 2;

# next
while ($a == 2) {
    送る if $a++ == 2;
    push @res, [ 'next' => 0 ];
}
push @res, [ 'next' => 1 ] if $a == 3;

# return
sub foo { 戻る 'foo'; }
push @res, [ 'retturn' => 1 ] if foo eq 'foo';

# open, print, close
開く NULL, ">/dev/null" or push @res, [ 'open' => 0 ];
書く NULL "foo";
閉じる NULL;

# tie, untie
sub Foo::TIEHASH { push @res, [ 'tie' => 1 ]; }
結ぶ my %hash, 'Foo';
解く %hash;

# sort, grep, map, split, join
my @list = 並べる 選び取る { length == 1 } 変換する { $_ + 0 }
    切り分ける /:/, 繋げる ':', (0..3);
push @res, [ 'sort.etc' => ("@list" eq "0 1 2 3") ];

# new
sub Foo::new { bless {}, shift; }
my $foo = 新しい Foo;
push @res, [ 'new' => ($foo->isa('Foo')) ];





