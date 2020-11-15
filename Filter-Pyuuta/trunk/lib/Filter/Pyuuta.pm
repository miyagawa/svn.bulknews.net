package Filter::Pyuuta;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use Filter::Simple;

my %map = (
    '�⤷'           => 'if',
    '�⤷����'       => 'elsif',
    '�ǤϤʤ����'   => 'else',
    'ȴ����'         => 'last',
    '���ľ��'       => 'redo',
    '����'           => 'next',
    '³����'         => 'while',
    '���'           => 'return',
    '�и�'           => 'exit',
    '��'           => 'print',
    '������������'   => 'my',
    '�֤��Ȥ���'     => 'local',
    '�֤ä��㤱����' => 'our',
    '����'           => 'open',
    '�Ĥ���'         => 'close',
    '���'           => 'tie',
    '��'           => 'untie',
    '�¤٤�'         => 'sort',
    '���Ӽ��'       => 'grep',
    '�Ѵ�����'       => 'map',
    '�ڤ�ʬ����'     => 'split',
    '�Ҥ���'         => 'join',
    '������'         => 'new',
    '�����������'   => 'foreach',
    '����'           => 'do',
);

my $regex = join '|', map quotemeta, sort { length $b <=> length $a } keys %map;
FILTER { s/($regex)/$map{$1}/og; };


1;
__END__

=head1 NAME

Filter::Pyuuta - Japanelizd development environment for Perl

=head1 SYNOPSIS

  use Filter::Pyuuta;
  ������������ $message = "����ˤ�������!\n";
  �� $message;

  no Filter::Pyuuta;
  print "������������"; # this won't be filtered

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

  ������������ $i �� ����;
  sub insert (�ϥå��� $tree �� �ɤ߽�, ���� $val) { }

=item *

Pluggable mapping table like JDE.pm.

=item *

C<������������> �ä�Ĺ���ʤ�?

=back

=head1 AUTHOR

Original code by Hiroyuki Oyama <oyama@crayfish.co.jp> as JDE::Pyuuta.

Maintained by Tatsuhiko Miyagawa <miyagawa@bulknews.net>

=head1 SEE ALSO

L<utf8>, L<Filter::Simple>

=cut
