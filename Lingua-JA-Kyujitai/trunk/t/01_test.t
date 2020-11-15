use Test::Base;
use Lingua::JA::Kyujitai;
use utf8;

plan tests => 1 * blocks;
filters { input => 'chomp', expected => 'chomp' };

run {
    my $block = shift;
    my $conv  = Lingua::JA::Kyujitai->new;
    is $conv->normalize($block->input), $block->expected, $block->name;
};

__END__

===
--- input
眞劍に檢討する
--- expected
真剣に検討する
