package Web::Scraper;
use strict;
use warnings;
use Carp;
use Scalar::Util 'blessed';
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;

our $VERSION = '0.03';

sub import {
    my $class = shift;
    my $pkg   = caller;

    no strict 'refs';
    *{"$pkg\::scraper"} = \&scraper;
    *{"$pkg\::process"}       = sub { goto &process };
    *{"$pkg\::process_first"} = sub { goto &process_first };
    *{"$pkg\::result"}        = sub { goto &result  };
}

my $ua;

sub __ua {
    require LWP::UserAgent;
    $ua ||= LWP::UserAgent->new(agent => __PACKAGE__ . "/" . $VERSION);
    $ua;
}

sub scraper(&) {
    my($coderef) = @_;

    sub {
        my $stuff = shift;
        my($html, $tree);

        if (blessed($stuff) && $stuff->isa('URI')) {
            require HTTP::Response::Encoding;
            my $ua  = __ua;
            my $res = $ua->get($stuff);
            if ($res->is_success) {
                $html = $res->decoded_content;
            } else {
                croak "GET $stuff failed: ", $res->status_line;
            }
        } elsif (blessed($stuff) && $stuff->isa('HTML::Element')) {
            $tree = $stuff->clone;
        } elsif (ref($stuff) && ref($stuff) eq 'SCALAR') {
            $html = $$stuff;
        } else {
            $html = $stuff;
        }

        $tree ||= do {
            my $t = HTML::TreeBuilder::XPath->new;
            $t->parse($html);
            $t;
        };

        my $stash = {};
        no warnings 'redefine';
        local *process       = create_process(0, $tree, $stash);
        local *process_first = create_process(1, $tree, $stash);

        local *result = sub {
            my @keys = @_;

            if (@keys == 1) {
                return $stash->{$keys[0]};
            } else {
                my %res;
                @res{@keys} = @{$stash}{@keys};
                return \%res;
            }
        };

        my $ret = $coderef->($tree);

        # check user specified return value
        return $ret if $ret;

        return $stash;
    };
}

sub create_process {
    my($first, $tree, $stash) = @_;

    sub {
        my($exp, @attr) = @_;

        my $xpath = HTML::Selector::XPath::selector_to_xpath($exp);
        my @nodes = $tree->findnodes($xpath) or return;
        @nodes = ($nodes[0]) if $first;

        while (my($key, $val) = splice(@attr, 0, 2)) {
            if (ref($key) && ref($key) eq 'CODE' && !defined $val) {
                for my $node (@nodes) {
                    $key->($node);
                }
            } elsif ($key =~ s!\[\]$!!) {
                $stash->{$key} = [ map get_value($_, $val), @nodes ];
            } else {
                $stash->{$key} = get_value($nodes[0], $val);
            }
        }

        return;
    };
}

sub get_value {
    my($node, $val) = @_;

    if (ref($val) && ref($val) eq 'CODE') {
        return $val->($node);
    } elsif ($val =~ s!^@!!) {
        return $node->attr($val);
    } elsif (lc($val) eq 'content' || lc($val) eq 'text') {
        return $node->as_text;
    } else {
        Carp::cluck "WTF";
    }
}

sub stub {
    my $func = shift;
    return sub {
        croak "Can't call $func() outside scraper block";
    };
}

*process       = stub 'process';
*process_first = stub 'process_first';
*result        = stub 'result';

1;
__END__

=for stopwords API SCRAPI Scrapi

=head1 NAME

Web::Scraper - Web Scraping Toolkit inspired by Scrapi

=head1 SYNOPSIS

  use URI;
  use Web::Scraper;

  my $ebay_auction = scraper {
      process "h3.ens>a",
          description => 'TEXT',
          url => '@href';
      process "td.ebcPr>span", price => "TEXT";
      process "div.ebPicture >a>img", image => '@src';

      result 'description', 'url', 'price', 'image';
  };

  my $ebay = scraper {
      process "table.ebItemlist tr.single",
          "auctions[]" => $ebay_auction;
      result 'auctions';
  };

  $ebay->( URI->new("http://search.ebay.com/apple-ipod-nano_W0QQssPageNameZWLRS") );

=head1 DESCRIPTION

Web::Scraper is a web scraper toolkit, inspired by Ruby's equivalent Scrapi.

B<THIS MODULE IS IN ITS BETA QUALITY. THE API IS STOLEN FROM SCRAPI BUT MAY CHANGE IN THE FUTURE>

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://blog.labnotes.org/category/scrapi/>

=cut
