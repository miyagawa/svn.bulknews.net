use strict;
use Test::More tests => 6;

# We can't use Filter::Simple related modules directly in tests

use vars qw(@res);		# scripts should store result to this array
do "./t/syntax.pl";

for (@res) {
    my($name, $val) = @$_;
    is $val, 1, $name;
}

