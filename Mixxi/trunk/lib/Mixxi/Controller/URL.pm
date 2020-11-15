package Mixxi::Controller::URL;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Mixxi::Controller::URL - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

}

sub create : Local {
    my($self, $c) = @_;

    die;

    my $url   = $c->req->param('url');
    my $alias = $c->req->param('alias');

    if ($alias && !$self->validate_alias($c, $alias)) {
        $c->stash->{error} = 'alias is taken or invalid';
        $c->stash->{template} = 'url/index.tt';
        return;
    }

    my $rec = $c->model('DBIC::Url')->create({
        url   => $url,
        alias => $alias || undef,
    });

    $c->res->redirect($c->uri_for('/') . $rec->canon_path);
}

sub validate : Local {
    my($self, $c) = @_;

    my $alias = $c->req->param('alias');
    if ($alias && !$self->validate_alias($c, $alias)) {
        $c->stash->{json_data}->{error} = 'alias is taken or invalid';
    } else {
        $c->stash->{json_data}->{error} = 0;
    }

    $c->forward($c->view('JSON'));
}

my %reserved_alias = map { $_ => 1 } qw( url id qr );

sub validate_alias {
    my($self, $c, $alias) = @_;
    $alias =~ /^[a-zA-Z0-9\-\_]{2,16}$/ or return;
    $alias =~ /^[0-9]+$/ and return;
    $reserved_alias{$alias} and return;

    my $rs = $c->model('DBIC::Url')->search(alias => $alias);
    $rs->count and return;

    return 1;
}

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
