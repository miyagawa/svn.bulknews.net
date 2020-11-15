use strict;
use Test::More;

use Text::Emoticon::Yahoo;

my $text = "blah ;)blah :D";

my @Tests = (
    # args, filtered_text
    [ { imgbase => '.' },
      qq(blah <img src="./3.gif" />blah <img src="./4.gif" />) ],
    [ { imgbase => "http://example.com/img" },
      qq(blah <img src="http://example.com/img/3.gif" />blah <img src="http://example.com/img/4.gif" />) ],
    [ { imgbase => '.', xhtml => 0 },
      qq(blah <img src="./3.gif">blah <img src="./4.gif">) ],
    [ { imgbase => '.', class => "emo" },
      qq(blah <img src="./3.gif" class="emo" />blah <img src="./4.gif" class="emo" />) ],
);

plan tests => scalar(@Tests);

for (@Tests) {
    my($args, $filtered) = @$_;
    my $emoticon = Text::Emoticon::Yahoo->new(%$args);
    is $emoticon->filter($text), $filtered;
}
