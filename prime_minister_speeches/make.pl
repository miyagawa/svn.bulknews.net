#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Encode;
use HTML::TagCloud;
use LWP::UserAgent;
use Text::Kakasi;
use HTML::TreeBuilder;
use HTML::FormatText;
use Template::Declare::Tags;

my %urls = (
    aso => "http://www.kantei.go.jp/jp/asospeech/2008/09/29housin.html",
    fukuda => " http://www.kantei.go.jp/jp/hukudaspeech/2007/10/01syosin.html",
    abe => "http://www.kantei.go.jp/jp/abespeech/2006/09/29syosin.html",
    koizumi => "http://www.kantei.go.jp/jp/koizumispeech/2001/0507syosin.html",
    hatoyama => "http://www.kantei.go.jp/jp/hatoyama/statement/200912/25kaiken.html",
);

my @names = (
    hatoyama => "Yukio Hatoyama",
    aso => "Taro Aso",
    fukuda => "Yasuo Fukuda",
    abe => "Shinzo Abe",
    koizumi => "Jun-ichiro Koizumi",
);

my %html;

for my $name (keys %urls) {
    my $file = "$name.html";
    my @words = extract_words($file);
    $html{$name} = build_html($file, @words);
}

build_index();

sub extract_words {
    my $file = shift;

    open my $fh, "<:encoding(shift_jis)", $file or die;
    my $content = join '', <$fh>;

    my $tree = HTML::TreeBuilder->new_from_content($content);
    my $text = HTML::FormatText->new->format($tree);
    $text =~ s/\s+//gs;

    my $res = Text::Kakasi->new(qw(-iutf8 -outf8 -w))->get($text);
    return grep is_skip_word($_), split /\s+/, $res;
}

sub build_html {
    my($file, @words) = @_;

    my %count;
    for my $w (@words) {
        $count{$w}++;
    }

    my $tagcloud = HTML::TagCloud->new;
    for my $w (keys %count) {
        $tagcloud->add($w, "#$w", $count{$w});
    }

    return $tagcloud->html(100);
}

sub is_skip_word {
    local $_ = shift;
    !/^[\p{IsHiragana}\p{IsPunct}\[a-zA-Z\]\d]+$/;
}

sub build_index {
    open my $out, ">:utf8", "index.html" or die;

    my $html = html {
        head {
            title { "Japanese Prime Minister Speech Cloud" };
            meta { http_equiv is "Content-Type"; content is "text/html;charset=utf-8" };
            link { rel is "stylesheet"; href is "screen.css" };
            style { outs_raw(HTML::TagCloud->new->css) };
        };
        body {
            div {
                class is "container";
                h1 { "Japanese Prime Minister Speech Cloud" };

                while (my($name, $fullname) = splice(@names, 0, 2)) {
                    h2 { style is "margin-bottom:0"; $fullname };
                    div { style is "padding-top:0;margin-top:0"; a { href is $urls{$name}; $urls{$name} } };
                    div { style is "margin-top: 1em; margin-bottom:1em"; outs_raw $html{$name} };
                }

                div {
                    style is "text-align:center;margin-top:3em";
                    outs "2009. Built by ";
                    a { href is "http://bulknews.vox.com/"; "Tatsuhiko Miyagawa" };
                    outs " using ";
                    a { href is "http://perl.org/"; "Perl" };
                    outs " and ";
                    a { href is "http://search.cpan.org/dist/Text-Kakasi/"; "Text::Kakasi" };
                    my $url = "http://blog.bulknews.net/prime_minister_speeches/";
                    a { href is "http://b.hatena.ne.jp/entry/$url";
                        img { src is "http://b.hatena.ne.jp/entry/image/$url" .  style is "vertical-align:middle" } };
                };
            };
        }
    };

    print $out $html;
}
