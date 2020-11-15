use strict;
use Template::Test;

test_expect(\*DATA);

__END__
--test--
[% USE Clickable -%]
[% FILTER clickable  finder_class => 'URI::Find::Schemeless' -%]
www.template-toolkit.org/foobar
[%- END %]
--expect--
<a href="http://www.template-toolkit.org/foobar">www.template-toolkit.org/foobar</a>
