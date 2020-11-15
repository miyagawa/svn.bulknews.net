use strict;
use Template::Test;

test_expect(\*DATA);

__END__
--test--
[% USE JavaScript -%]
document.write("[% FILTER js %]
Here's some text going on.
[% END %]");
--expect--
document.write("\nHere\'s some text going on.\n");

