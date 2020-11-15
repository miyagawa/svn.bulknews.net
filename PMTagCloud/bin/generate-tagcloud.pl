#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use File::Basename;
use File::Find::Rule;
use HTML::TagCloud;
use Template;
use YAML;
use URI::Escape;

my @order = qw(abe koizumi mori obuti hashimoto murayama);
my %pm_order = map { $order[$_] => $_ } 0..$#order;

my %data = (
    abe => {
        name => '安倍晋三 (Shinzo Abe)',
        img  => 'http://www.kantei.go.jp/top-images2006/abe_souri.jpg',
    },
    koizumi => {
        name => '小泉純一郎 (Junichiro Koizumi)',
        img  => 'http://www.kantei.go.jp/jp/koizumiprofile/images/sokaku.jpg',
    },
    mori => {
        name => '森喜朗 (Yoshiro Mori)',
        img  => 'http://www.kantei.go.jp/top-images2001/mori.gif',
    },
    obuti => {
        name => '小渕恵三 (Keizo Obuchi)',
        img  => 'http://www.kantei.go.jp/top-images2001/obuchi.gif',
    },
    hashimoto => {
        name => '橋本龍太郎 (Ryutaro Hashimoto)',
        img  => 'http://www.kantei.go.jp/top-images2001/hashimoto.gif',
    },
    murayama => {
        name => '村山富市 (Tomiichi Murayama)',
        img  => 'http://www.kantei.go.jp/top-images2001/murayama.gif',
    },
);

my $dump  = "$FindBin::Bin/../data/dump";
my @files = File::Find::Rule->file->in($dump);

my $out   = "$FindBin::Bin/../output";

my $stash;
$stash->{data} = \%data;
$stash->{css} = HTML::TagCloud->new->css;

for my $file (@files) {
    my $base = basename($file);
    my $data = eval { YAML::LoadFile($file) } or next;

    my $cloud = HTML::TagCloud->new;
    for my $term (keys %$data) {
        my $uri = '#' . uri_escape($term);
        $cloud->add($term, $uri, $data->{$term});
    }

    my($pm, $year) = $base =~ /(\w+)-(\d+)\.yml/;
    push @{$stash->{clouds}}, { pm => $pm, year => $year, cloud => $cloud };
}

$stash->{clouds} = [
    sort { $a->{year} <=> $b->{year} || $pm_order{$b->{pm}} <=> $pm_order{$a->{pm}} }
    @{$stash->{clouds}}
];

my $tt = Template->new;
my $tmpl = join '', <DATA>;
$tt->process(\$tmpl, $stash, "output/index.html")
    or die $tt->error;

__DATA__
<html>
<head><title>Japanese Prime Minister Speeches Tag Cloud - 日本の首相演説のタグクラウド</title>
<script type="text/javascript" src="js/range.js"></script>
<script type="text/javascript" src="js/timer.js"></script>
<script type="text/javascript" src="js/slider.js"></script>
<link type="text/css" rel="StyleSheet" href="css/winclassic.css" />
<style>
.tl { display: none }
body { font-size: 12px }
.footer { font-size: 10px }
[% css %]
#htmltagcloud { line-height: 1 }
</style>
</head>
<body>
<h1>Japanese Prime Minister Speeches Tag Cloud</h1>
<p class="description">
    Inspired by <a href="http://chir.ag/phernalia/preztags/">US Presidential Speeches Tag Cloud</a>.
</p>

<div class="slider" id="slider-1" tabIndex="1">
   <input class="slider-input" id="slider-input-1"
    name="slider-input-1"/>
</div>
<br />

<script type="text/javascript">
google_ad_client = "pub-0854756127426271";
google_ad_width = 728;
google_ad_height = 100;
google_ad_format = "728x90_as";
google_color_border = "FFFFFF";
google_color_bg = "FFFFFF";
google_color_link = "0000FF";
google_color_url = "000000";
google_color_text = "000000";
google_ad_channel ="2602048679";
google_alternate_ad_url = "http://blog.bulknews.net/adsense_alt.cgi";
</script>
<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>

[% FOREACH c = clouds %]
[% SET pm = c.pm -%]
<div class=tl id=tl_[% loop.count %]>
<h3>[% data.$pm.name | html %] ([% c.year %])</h3>
[% c.cloud.html(250) %]
</div>
[% END %]

<script type="text/javascript">
var s = new Slider(document.getElementById("slider-1"), document.getElementById("slider-input-1"));
s.setMinimum(1);
s.setMaximum([% clouds.size %]);
s.setValue(s.getMaximum());
s.onchange = function () { sv = s.getValue(); if(sv != last_tl) { document.getElementById('tl_'+sv).style.display = 'block'; document.getElementById('tl_'+last_tl).style.display = 'none'; last_tl = sv; } };

var last_tl = s.getValue();
document.getElementById('tl_'+last_tl).style.display = 'block';
</script>

<p class="footer">Copyright 2006 Tatsuhiko Miyagawa. Data collected from <a href="http://www.kantei.go.jp/jp/abespeech/index.html">kantei.go.jp</a>, analyzed using <a href="http://www.perl.org/">Perl</a> with <a href="http://search.cpan.org/dist/HTML-Tree/">HTML::TreeBuilder</a>, <a href="http://mecab.sourceforge.net/">mecab</a> and <a href="http://search.cpan.org/dist/Text-MeCab/">Text::MeCab</a>.
</p>

</body>
</html>
