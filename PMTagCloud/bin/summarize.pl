#!/usr/bin/perl
use strict;
use utf8;
use warnings;
use DateTime;
use Encode;
use File::Find::Rule;
use File::Spec;
use FindBin;
use HTML::TreeBuilder;
use Encode::Detect::Detector;
use Text::MeCab;
use YAML;

our $MecabEncoding = "euc-jp";

my $base = File::Spec->catfile($FindBin::Bin, "..", "data");
my @files = File::Find::Rule->file->name('*.html')->in($base);

mkdir "$base/dump", 0777 unless -e "$base/dump";

my %data;
for my $file (@files) {
    my($pm, $path) = (my $f = $file) =~ m!^$base/(\w+)/(.*?)$!;

    warn "reading $file";
    my $enc = guess_enc($file);
    open my $fh, "<:encoding($enc)", $file;

    my $tree = HTML::TreeBuilder->new;
    $tree->parse_file($fh);

    my $text = $tree->as_text;
    my $date = find_date($path, $text) or next;
    next if $date->year < 1900;

    $text = encode($MecabEncoding, $text);

    my $key = join "-", $pm, $date->year;

    my $mecab = Text::MeCab->new;
    for (my $node = $mecab->parse($text); $node; $node = $node->next) {
        my $feature = decode($MecabEncoding, $node->feature);
        my $surface = decode($MecabEncoding, $node->surface);
        if ($feature =~ /^名詞/ && $feature !~ /(非自立|代名詞|数|接尾)/) {
            $data{$key}{$surface}++;
        }
    }
}

for my $key (keys %data) {
    YAML::DumpFile("$base/dump/$key.yml", $data{$key});
}

sub guess_enc {
    my $file = shift;

    open my $fh, "<", $file or die $!;
    my $data = join '', <$fh>;

    Encode::Detect::Detector::detect($data);
}

sub find_date {
    my($path, $text) = @_;

    if ($path =~ /(\d{4})(?:%2F)?(\d\d?)(?:%2F)?(\d{2})/i) {
        if ($2 <= 12) {
            return DateTime->new(year => $1, month => $2, day => $3);
        }
    }

    if ($path =~ /(\d{4})(?:%2F)?.*-(\d\d?)(\d{2})\.html/i) {
        if ($2 <= 12) {
            return DateTime->new(year => $1, month => $2, day => $3);
        }
    }

    if ($text =~ /平成(\d+)年(\d+)月(\d+)日/) {
        return DateTime->new(year => 1988 + norm($1), month => norm($2), day => norm($3));
    }

    if ($path =~ /(19\d{2})/) {
        return DateTime->new(year => $1, month => 1, day => 1);
    }
}

sub norm {
    my $str = shift;
    $str =~ tr/０-９/0-9/;
    return $str;
}
