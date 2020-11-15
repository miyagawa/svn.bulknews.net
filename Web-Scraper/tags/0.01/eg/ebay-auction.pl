#!/usr/bin/perl
use strict;
use warnings;
use URI;
use lib "lib";
use Web::Scraper;

my $ebay_auction = scraper {
    process "h3.ens>a",
        description => 'content',
        url => '@href';
    process "td.ebcPr>span", price => "content";
    process "div.ebPicture >a>img", image => '@src';
    result 'description', 'url', 'price', 'image';
};

my $ebay = scraper {
    process "table.ebItemlist tr.single",
        "auctions[]" => $ebay_auction;
    result 'auctions';
};

my $auctions = $ebay->( URI->new("http://search.ebay.com/apple-ipod-nano_W0QQssPageNameZWLRS") );

use YAML;
warn Dump $auctions;

