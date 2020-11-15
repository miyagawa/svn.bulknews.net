package Mixxi::Controller::QRcode;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Mixxi::Controller::QRcode - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

use GD::Barcode::QRcode;

sub qr : Global {
    my ( $self, $c, $alias, $id ) = @_;

    my $url;
    eval {
        if ($alias eq 'u') {
            $id = Mixxi::Schema::Url->to_id($id) or die "No id";
            $url = $c->model('DBIC::Url')->find($id);
        } else {
            my $rs = $c->model('DBIC::Url')->search(alias => $alias);
            $rs->count or die "No url matched $alias";
            $url = $rs->first;
        }
    };

    if ($@ || !$url) {
        return $c->res->redirect($c->uri_for('/url'));
    }

    $c->stash->{qrcode} = $url->url;
    $c->forward( $c->view('QRcode') );
}


=head1 AUTHOR

Tatsuhiko Miyagawa,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
