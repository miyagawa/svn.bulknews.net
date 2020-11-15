package WebService::Bloglines::Entries;

use vars qw($VERSION);
$VERSION = 0.08;

use strict;
use XML::RSS::LibXML;
use XML::LibXML;
use HTML::Entities;

sub parse {
    my($class, $xml) = @_;

    # temporary workaround till Bloglines fixes this bug
    $xml =~ s!<webMaster>(.*?)</webMaster>!HTML::Entities::encode($1)!eg;

    my $parser = XML::LibXML->new;
    my $doc    = $parser->parse_string($xml);
    my $rssparent   = $doc->find("/rss")->get_node(0);
    my $channelnode = $doc->find("/rss/channel");
    $rssparent->removeChildNodes();

    my @entries;
    for my $node ($channelnode->get_nodelist()) {
	my $xml = $rssparent->toString();
	my $channel = $node->toString();
	$xml =~ s!<(rss.*?)/>$!<$1>\n$channel\n</rss>!; # wooh
	push @entries, $class->new($xml);
    }
    return wantarray ? @entries : $entries[0];
}

sub new {
    my($class, $xml) = @_;
    my $self = bless {
	_xml => $xml,
    }, $class;
    $self->_parse_xml();
    $self;
}

sub _parse_xml {
    my $self = shift;

    my $rss = XML::RSS::LibXML->new();
    $rss->add_module(prefix => "bloglines", uri => "http://www.bloglines.com/services/module");
    $rss->parse($self->{_xml});
    $self->{_rss} = $rss;
}

sub feed {
    my $self = shift;
    return $self->{_rss}->{channel};
}

sub items {
    my $self = shift;
    return wantarray ? @{$self->{_rss}->{items}} : $self->{_rss}->{items};
}

1;

