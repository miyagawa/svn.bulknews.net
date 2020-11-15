#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use LWP::UserAgent;
use URI;
use URI::Escape;
use YAML;

our $Seed = YAML::Load(<<YAML);
abe:
  - http://www.kantei.go.jp/jp/abespeech/index.html
koizumi:
  - http://www.kantei.go.jp/jp/koizumispeech/index.html
  - http://www.kantei.go.jp/jp/koizumispeech/2005/index.html
  - http://www.kantei.go.jp/jp/koizumispeech/2004/index.html
  - http://www.kantei.go.jp/jp/koizumispeech/2003/index.html
  - http://www.kantei.go.jp/jp/koizumispeech/2002/index.html
  - http://www.kantei.go.jp/jp/koizumispeech/2001/index.html
mori:
  - http://www.kantei.go.jp/jp/morisouri/mori_speech/index.html
obuti:
  - http://www.kantei.go.jp/jp/obutisouri/speech/index.html
hashimoto:
  - http://www.kantei.go.jp/jp/hasimotosouri/speech/index.html
murayama:
  - http://www.kantei.go.jp/jp/murayamasouri/speech/index.html
  - http://www.kantei.go.jp/jp/murayamasouri/danwa/index.html
YAML

our $ua = LWP::UserAgent->new;

for my $pm (sort keys %$Seed) {
    aggregate($pm, $Seed->{$pm});
}

sub aggregate {
    my($pm, $urls) = @_;

    for my $url (@$urls) {
        my @links = find_links($url);
        for my $link (@links) {
            fetch_story($pm, $url, $link);
        }
    }
}

sub find_links {
    my($url) = @_;

    warn "find links from $url";

    my $html = $ua->get($url)->content;
    my @links = $html =~ m!<a href="([^/][^"]+\.html)">!gi;

    return grep !/index\.html/, @links;
}

sub fetch_story {
    my($pm, $base, $link) = @_;

    my $dir  = File::Spec->catfile($FindBin::Bin, "..", 'data', $pm);
    mkdir $dir, 0777 unless -e $dir;

    my $url = URI->new_abs($link, $base);

    (my $fn = $url->as_string) =~ s!.*speech/!!;
    my $path = File::Spec->catfile($dir, uri_escape($fn));

    warn "mirroring $url";

    $ua->mirror($url, $path);
}
