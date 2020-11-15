#!/usr/bin/perl
use strict;
use warnings;
use lib "lib";
use Lingua::JA::Kyujitai;
use encoding 'utf-8';

my $conv = Lingua::JA::Kyujitai->new;
while (<>) {
    print $conv->normalize($_);
}
