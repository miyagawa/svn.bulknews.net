use strict;
use Test::More 'no_plan';

use Inline 'TT';

is rubyish(str => "Just another Perl hacker"), "Just/another/Ruby/hacker";

__END__
__TT__
[% BLOCK rubyish -%]
[% strings = str.split(' ')
   strings.2 = "Ruby" %]
[% strings.join('/') %]
[%- END %]
