use strict;
use Test::More;

my $url = $ENV{OPENSEARCH_URL};
unless ($url) {
    Test::More->import(skip_all => "OPENSEARCH_URL not set");
    exit;
}

plan 'no_plan';

use WWW::Blog::Metadata;
require WWW::OpenSearch;

my $meta = WWW::Blog::Metadata->extract_from_uri($url)
    or die WWW::Blog::Metadata->errstr;
my $xml = $meta->opensearch_description;
ok $xml, $xml;

my $opensearch = WWW::OpenSearch->new($xml);
my $feed = $opensearch->search('blog');
ok $feed;

