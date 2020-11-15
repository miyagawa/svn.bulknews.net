use strict;
use Filter::Pyuuta;

use vars qw(@res);		# elements: [ testname => 0, 1 ]

my $a = 0;

# if, elsif, else
�⤷ ($a == 0) {
    push @res, [ 'if' => 1 ];
} �⤷���� ($a == 1) {
    push @res, [ 'elsif' => 0 ];
} �ǤϤʤ���� {
    push @res, [ 'else' => 0 ];
}

# while, last
³���� (1) {
    push @res, [ 'while' => 1 ];
    ȴ����;
}

# redo
{
    ���ľ�� while ++$a == 2;
}

push @res, [ 'redo' => 1 ] if $a == 2;

# next
while ($a == 2) {
    ���� if $a++ == 2;
    push @res, [ 'next' => 0 ];
}
push @res, [ 'next' => 1 ] if $a == 3;

# return
sub foo { ��� 'foo'; }
push @res, [ 'retturn' => 1 ] if foo eq 'foo';

# open, print, close
���� NULL, ">/dev/null" or push @res, [ 'open' => 0 ];
�� NULL "foo";
�Ĥ��� NULL;

# tie, untie
sub Foo::TIEHASH { push @res, [ 'tie' => 1 ]; }
��� my %hash, 'Foo';
�� %hash;

# sort, grep, map, split, join
my @list = �¤٤� ���Ӽ�� { length == 1 } �Ѵ����� { $_ + 0 }
    �ڤ�ʬ���� /:/, �Ҥ��� ':', (0..3);
push @res, [ 'sort.etc' => ("@list" eq "0 1 2 3") ];

# new
sub Foo::new { bless {}, shift; }
my $foo = ������ Foo;
push @res, [ 'new' => ($foo->isa('Foo')) ];





