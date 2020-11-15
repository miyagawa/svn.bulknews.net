package Filter::Pyuuta;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use Filter::Simple;

my %map = (
    'もし'           => 'if',
    'もしくは'       => 'elsif',
    'ではない場合'   => 'else',
    '抜ける'         => 'last',
    'やり直し'       => 'redo',
    '送る'           => 'next',
    '続ける'         => 'while',
    '戻る'           => 'return',
    '出口'           => 'exit',
    '書く'           => 'print',
    'ここだけの話'   => 'my',
    '置いといて'     => 'local',
    'ぶっちゃけた話' => 'our',
    '開く'           => 'open',
    '閉じる'         => 'close',
    '結ぶ'           => 'tie',
    '解く'           => 'untie',
    '並べる'         => 'sort',
    '選び取る'       => 'grep',
    '変換する'       => 'map',
    '切り分ける'     => 'split',
    '繋げる'         => 'join',
    '新しい'         => 'new',
    'これだけする'   => 'foreach',
    'する'           => 'do',
);

my $regex = join '|', map quotemeta, sort { length $b <=> length $a } keys %map;
FILTER { s/($regex)/$map{$1}/og; };


1;
__END__

=head1 NAME

Filter::Pyuuta - Japanelizd development environment for Perl

=head1 SYNOPSIS

  use Filter::Pyuuta;
  ここだけの話 $message = "こんにちは世界!\n";
  書く $message;

  no Filter::Pyuuta;
  print "ここだけの話"; # this won't be filtered

=head1 DESCRIPTION

Filter::Pyuuta is a complete rewrite of JDE.pm using
Filter::Simple. Believe me or not, JDE.pm has enabled programming in
Japanese for a long time without Filter module!

=head1 CAVEAT

This module might raise some troubles when you use in production
environment. Use at your own risk.

=head1 TODO

=over 4

=item *

Perl 6 syntax support.

  use Filter::Pyuuta 'perl6';

  ここだけの話 $i は 整数;
  sub insert (ハッシュ $tree は 読み書き, 整数 $val) { }

=item *

Pluggable mapping table like JDE.pm.

=item *

C<ここだけの話> って長くない?

=back

=head1 AUTHOR

Original code by Hiroyuki Oyama <oyama@crayfish.co.jp> as JDE::Pyuuta.

Maintained by Tatsuhiko Miyagawa <miyagawa@bulknews.net>

=head1 SEE ALSO

L<utf8>, L<Filter::Simple>

=cut
