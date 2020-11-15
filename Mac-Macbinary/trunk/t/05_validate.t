use strict;
use Test;
BEGIN { plan tests => 1 }
use Mac::Macbinary;

my $mb = new Mac::Macbinary "t/test.mb", { validate => 1 };
ok($mb->header->name, "test.txt");

