use strict;
use Template::Plugin::Properties;
use Template::Test;

test_expect(\*DATA);

__END__
--test--
[% USE props = Properties('t/props') -%]
[% FOREACH name = props.names.sort -%]
[% name %] = [% props.get(name) %]
[% END -%]
baz = [% props.get('baz', 'default baz') %]
--expect--
bar = baz
foo = bar
baz = default baz

--test--
[% USE props = Properties -%]
[% props.set('foo.bar' => 'baz') -%]
foo.bar = [% props.get('foo.bar') %]
--expect--
foo.bar = baz

--test--
[% USE props = Properties -%]
[% text = BLOCK -%]
foo.bar=baz
[% END -%]
[% props.parse(text) -%]
foo.bar = [% props.get('foo.bar') %]
--expect--
foo.bar = baz

