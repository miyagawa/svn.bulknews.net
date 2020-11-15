package Lingua::JA::Kyujitai;

use strict;
our $VERSION = '0.01';

use utf8;
use Carp;

my @kyujitai = qw(
    亜亞  悪惡  圧壓  囲圍  為爲  医醫  壱壹  稲稻  飲飮  隠隱
    営營  栄榮  衛衞  駅驛  円圓  艶艷  塩鹽  奥奧  応應  欧歐
    殴毆  穏穩  仮假  価價  画畫  会會  壊壞  懐懷  絵繪  拡擴
    殻殼  覚覺  学學  岳嶽  楽樂  勧勸  巻卷  歓歡  缶罐  観觀
    関關  陥陷  巌巖  顔顏  帰歸  気氣  亀龜  偽僞  戯戲  犠犧
    旧舊  拠據  挙擧  峡峽  挟挾  狭狹  暁曉  区區  駆驅  勲勳
    径徑  恵惠  渓溪  経經  継繼  茎莖  蛍螢  軽輕  鶏鷄  芸藝
    欠缺  倹儉  剣劍  圏圈  検檢  権權  献獻  県縣  険險  顕顯
    験驗  厳嚴  効效  広廣  恒恆  鉱鑛  号號  国國  済濟  砕碎
    斎齋  剤劑  桜櫻  冊册  雑雜  参參  惨慘  桟棧  蚕蠶  賛贊
    残殘  糸絲  歯齒  児兒  辞辭  湿濕  実實  舎舍  写寫  釈釋
    寿壽  収收  従從  渋澁  獣獸  縦縱  粛肅  処處  叙敍敘  奨奬獎
    将將  焼燒  称稱  証證  乗乘  剰剩  壌壤  嬢孃  条條  浄淨
    畳疊  穣穰  譲讓  醸釀  嘱囑  触觸  寝寢  慎愼  晋晉  真眞
    尽盡  図圖  粋粹  酔醉  随隨膸  髄髓  数數  枢樞  声聲  静靜
    斉齊  摂攝  窃竊  専專  戦戰  浅淺  潜潛濳  繊纖纎  践踐  銭錢
    禅禪  双雙  壮壯  捜搜  挿插  争爭  総總  聡聰  荘莊  装裝
    騒騷  臓臟  蔵藏  属屬  続續  堕墮  体體  対對  帯帶  滞滯
    台臺  滝瀧  択擇  沢澤  単單  担擔  胆膽  団團  弾彈  断斷
    痴癡  遅遲  昼晝  虫蟲  鋳鑄  庁廳  聴聽  鎮鎭  逓遞  鉄鐵
    転轉  点點  伝傳  党黨  盗盜  灯燈  当當  闘鬪  独獨  読讀
    届屆  縄繩  弐貳  悩惱  脳腦  廃廢  拝拜  売賣  麦麥  発發
    髪髮  抜拔  蛮蠻  秘祕  浜濱  払拂  仏佛  並竝  変變  辺邊邉
    弁辨辯瓣  舗舖  穂穗  宝寶  豊豐  没沒  万萬  満滿  黙默  弥彌
    薬藥  訳譯  藪薮  予豫  余餘  与與  誉譽  揺搖  様樣  謡謠
    来來  乱亂  覧覽  竜龍  両兩  猟獵  塁壘  励勵  礼禮  隷隸
    霊靈  齢齡  恋戀  炉爐  労勞  楼樓  禄祿  湾灣
);

my @itaiji = qw(
    芦蘆  鯵鰺  欝鬱  厩廏  曳曵  煙烟  鴬鶯  蛎蠣  鈎鉤  撹攪
    竃竈  潅灌  諌諫  却卻  憩憇  携攜  頚頸  砿礦  皐皋  讃讚
    刃刄  靭靱  翠翆  線綫  賎賤  曽曾  稚穉  勅敕  壷壺  纏纒
    涛濤  妊姙  祢禰  覇霸  蝿蠅  函凾  桧檜  萌萠  褒襃  冒冐
    翻飜  侭儘  餅餠  篭籠  伜倅  僣僭  懴懺  抬擡  昿曠  枡桝
    檪櫟  殱殲  珱瓔  畴疇  筝箏  籖籤  緕纃  羮羹  腟膣  虱蝨
    譛譖  逎遒  鈬鐸  鈩鑪  鑚鑽  鵞鵝  鷏鷆  麸麩  尭堯  遥遙
    亘亙  穐龝  箆篦  往徃  嘩譁  券劵  竪豎  厨廚  槙槇  瑶瑤
    薮藪  陰蔭  付附  連聯  言云  罰罸
);

# http://en.wikipedia.org/wiki/Jinmeiyo_kanji#List_of_the_traditional_kanji_tolerated_in_names
my @names = qw(
    亜亞  悪惡  為爲  衛衞  謁谒  縁緣  応應
    桜櫻  奥奧  横橫  温溫  価價  禍祸  悔祉  壊壞
    懐懷  楽樂  渇渴  巻卷  陥陷  寛寬  気氣  偽僞
    戯戲  虚虛  峡峽  狭狹  暁曉  勲勳  薫薰  恵惠
    掲揭  鶏鷄  芸藝  撃擊  県縣  倹儉  剣劍  険險
    圏圈  検檢  顕顯  験驗  厳嚴  広廣  恒恆  黄黃
    国國  黒黑  砕碎  雑雜  児兒  湿濕  寿壽  収收
    従從  渋澁  獣獸  縦縱  緒緖  叙敍  将將  渉涉
    焼燒  奨獎  条條  状狀  乗乘  浄淨  剰剩  畳疊
    嬢孃  譲讓  醸釀  真眞  寝寢  慎愼  尽盡  粋粹
    酔醉  穂穗  瀬瀨  斉齊  静靜  摂攝  専專  戦戰
    繊纖  禅禪  壮壯  争爭  荘莊  捜搜  巣巢  装裝
    騒騷  増增  蔵藏  臓臟  即卽  帯帶  滞滯  単單
    団團  弾彈  昼晝  鋳鑄  著節  庁廳  徴徵  聴聽
    鎮鎭  転轉  伝傳  灯燈  盗盜  稲稻  徳德  拝拜
    売賣  髪髮  抜拔  晩晚  秘祕  払拂  仏佛  歩步
    翻飜  毎每  黙默  薬藥  与與  揺搖  様樣  謡謠
    来來  頼賴  覧覽  竜龍  緑綠  涙淚  塁壘  暦曆
    歴歷  錬鍊  郎郞  録錄
);

our %Conv;
for (@kyujitai, @itaiji, @names) {
    my($new, @old) = split //;
    for my $old (@old) {
        $Conv{$old} = $new;
    }
}

our $RE = "[" . join('', keys %Conv) . "]";

sub new {
    bless {}, shift;
}

sub normalize {
    my($self, $text) = @_;
    return unless $text;
    croak "input should be UTF-8 flagged" unless utf8::is_utf8($text);

    $text =~ s/($RE)/$Conv{$1}/g;
    $text;
}

1;
__END__

=encoding utf-8

=head1 NAME

Lingua::JA::Kyujitai - Normalize Kyujitai (旧字体) to Shinjitai (新字体)

=head1 SYNOPSIS

  use Lingua::JA::Kyujitai;

  my $conv = Lingua::JA::Kyujitai->new;
  $conv->normalize("眞劍に檢討する"); # 真剣に検討する

=head1 DESCRIPTION

Lingua::JA::Kyujitai is a module to normalize Kyujitai (旧字体) to
Shinjitai (新字体).

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 ACKNOWLEDGEMENT

Kyujitai to Shinjitai mapping table is taken, or auto-generated using
the programs or data available at L<http://www.hyuki.com/aozora/>,
L<http://en.wikipedia.org/wiki/Jinmeiyo_kanji> and
L<http://greengablez.net/wx310kdic/>.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Kyujitai>
L<http://en.wikipedia.org/wiki/Shinjitai>
L<http://en.wikipedia.org/wiki/Jinmeiyo_kanji#List_of_the_traditional_kanji_tolerated_in_names>

=cut
