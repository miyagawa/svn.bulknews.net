package Mixxi::Controller::About;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Mixxi::Controller::About - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c, $alias, $id ) = @_;

    my $alias = $c->req->args->[0];
    my $id    = $c->req->args->[1];

    my $url;
    eval {
        $alias = $id if $alias eq 'a';

        unless ($alias || $id) {
            die "No alias nor id";
        }

        if ($alias eq 'u') {
            $id = Mixxi::Schema::Url->to_id($id) or die "No id";
            $url = $c->model('DBIC::Url')->find($id);
        } else {
            my $rs = $c->model('DBIC::Url')->search(alias => $alias);
            $rs->count or die "No url matched $alias";
            $url = $rs->first;
        }
        $c->stash->{template} = 'about.tt';
        $c->stash->{url} = $url;
    };

    if ($@ || !$url) {
        return $c->res->redirect($c->uri_for('/url'));
    }
}

=head1 AUTHOR

Tatsuhiko Miyagawa,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
