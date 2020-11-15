package MT::Plugin::Emoticon;

use strict;
use Text::Emoticon 0.03;
our $VERSION = "1.01";

our $EmoticonClass = 'MSN';
MT::Template::Context->add_global_filter(emoticon => \&emoticon);

sub emoticon {
    my $content = shift;
    my $emoticon = Text::Emoticon->new($EmoticonClass);
    return return $emoticon->filter($content);
}

1;
