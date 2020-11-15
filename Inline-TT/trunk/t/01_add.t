use strict;
use Test::More 'no_plan';

use Inline 'TT';

is add(args => [ 0, 1 ]), 1, "0 + 1 = 1";
is add(args => [ -100, 100 ]), 0, "-100 + 100 = 0";

__END__
__TT__
[% BLOCK add %]
[% result = 0 %]
[% FOREACH arg = args %]
  [% result = result + arg %]
[% END %]
[% result %]
[%- END %]
