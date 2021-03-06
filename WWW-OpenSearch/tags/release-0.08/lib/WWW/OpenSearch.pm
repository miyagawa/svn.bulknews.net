package WWW::OpenSearch;

use strict;
use warnings;

use base qw( Class::Accessor::Fast );

use Carp;
use WWW::OpenSearch::Response;
use WWW::OpenSearch::Description;
use Encode qw( _utf8_off ); 

__PACKAGE__->mk_accessors( qw( description_url agent description ) );

our $VERSION = '0.08';

=head1 NAME

WWW::OpenSearch - Search A9 OpenSearch compatible engines

=head1 SYNOPSIS

    use WWW::OpenSearch;
    
    my $url = "http://bulkfeeds.net/opensearch.xml";
    my $engine = WWW::OpenSearch->new($url);
    
    my $name = $engine->description->ShortName;
    my $tags = $engine->description->Tags;
    
    # Perform search for "iPod"
    my $response = $engine->search("iPod");
    for my $item (@{$response->feed->items}) {
        print $item->{description};
    }
    
    # Retrieve the next page of results
    my $next_page = $response->next_page;
    for my $item (@{$next_page->feed->items}) {
        print $item->{description};
    }

=head1 DESCRIPTION

WWW::OpenSearch is a module to search A9's OpenSearch compatible search engines. See http://opensearch.a9.com/ for details.

=head1 CONSTRUCTOR

=head2 new( $url [, $useragent] )

Constructs a new instance of WWW::OpenSearch using the given
URL as the location of the engine's OpenSearch Description
document (retrievable via the description_url accessor). Pass any
LWP::UserAgent compatible object if you wish to override the default
agent.

=head1 METHODS

=head2 fetch_description( [ $url ] )

Fetches the OpenSearch Descsription found either at the given URL
or at the URL specified by the description_url accessor. Fetched
description may be accessed via the description accessor.

=head2 search( $query [, \%params] )

Searches the engine for the given query using the given 
search parameters. Valid search parameters include:

=over 4

=item * startPage

=item * totalResults

=item * startIndex

=item * itemsPerPage

=back

See http://opensearch.a9.com/spec/1.1/response/#elements for details.

=head2 do_search( $url [, $method] )

Performs a request for the given URL and returns a
WWW::OpenSearch::Response object. Method defaults to 'GET'.

=head1 ACCESSORS

=head2 description_url( [$description_url] )

=head2 agent( [$agent] )

=head2 description( [$description] )

=head1 AUTHOR

=over 4

=item * Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Tatsuhiko Miyagawa and Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

sub new {
    my( $class, $url, $agent ) = @_;
    
    croak( "No OpenSearch Description url provided" ) unless $url;
    
    my $self = $class->SUPER::new;

    unless( $agent ) {
        require LWP::UserAgent;
        $agent = LWP::UserAgent->new( agent => join( '/', ref $self, $VERSION ) );
    }

    $self->description_url( $url );
    $self->agent( $agent );

    $self->fetch_description;
    
    return $self;
}

sub fetch_description {
    my( $self, $url ) = @_;
    $url ||= $self->description_url;
    $self->description_url( $url );
    my $response = $self->agent->get( $url );
    
    unless( $response->is_success ) {
        croak "Error while fetching $url: " . $response->status_line;
    }

    $self->description( WWW::OpenSearch::Description->new( $response->content ) );
}

sub search {
    my( $self, $query, $params ) = @_;

    $params ||= { };
    $params->{ searchTerms } = $query;
    _utf8_off( $params->{ searchTerms } ); 
    
    my $url = $self->description->get_best_url;
    return $self->do_search( $url->prepare_query( $params ), $url->method );
}

sub do_search {
    my( $self, $url, $method ) = @_;
    
    $method = lc( $method ) || 'get';
    
    my $response;
    if( $method eq 'post' ) {
        $response = $self->agent->post( @$url );
    }
    else {
        $response = $self->agent->$method( $url );
    }
    
    return WWW::OpenSearch::Response->new( $self, $response );    
}

1;
