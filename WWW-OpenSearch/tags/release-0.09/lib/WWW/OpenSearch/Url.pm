package WWW::OpenSearch::Url;

use strict;
use warnings;

use base qw( Class::Accessor::Fast );

use URI;
use URI::Escape;

__PACKAGE__->mk_accessors( qw( type template method params macros ) );

=head1 NAME

WWW::OpenSearch::Url - Object to represent a target URL

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new( [%options] )

=head1 METHODS

=head2 parse_macros( )

=head2 prepare_query( [ \%params ] )

=head1 ACCESSORS

=over 4

=item * type

=item * template

=item * method

=item * params

=item * macros

=back

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
    my( $class, %options ) = @_;
    
    $options{ method } ||= 'GET';
    $options{ template } = URI->new( $options{ template } );
    
    my $self = $class->SUPER::new( \%options );
    $self->parse_macros;

    return $self;
}

sub parse_macros {
    my $self = shift;
    
    my %query = $self->method eq 'post'
        ? %{ $self->params }
        : $self->template->query_form;
    
    my %macros;
    for( keys %query ) {
        if( $query{ $_ } =~ /^{(.+)}$/ ) {
            $macros{ $1 } = $_;
        }
    }
    
    $self->macros( \%macros );
}

sub prepare_query {
    my( $self, $params ) = @_;
    my $url   = $self->template->clone;
    
    $params->{ startIndex     } ||= 1;
    $params->{ startPage      } ||= 1;
    $params->{ language       } ||= '*';
    $params->{ outputEncoding } ||= 'UTF-8';
    $params->{ inputEncoding  } ||= 'UTF-8';
    
    my $macros = $self->macros;

    # attempt to handle POST
    if( $self->method eq 'post' ) {
        my $post = $self->params;
        for( keys %$macros ) {
            $post->{ $macros->{ $_ } } = $params->{ $_ };
        }
        return [ $url, $post ];
    }

    my $query = { $url->query_form };
    for( keys %$macros ) {
        $query->{ $macros->{ $_ } } = $params->{ $_ };
    }
    
    $url->query_form( $query );
    return $url;
}

1;
