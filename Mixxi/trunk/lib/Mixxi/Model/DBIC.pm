package Mixxi::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Mixxi::Schema',
    connect_info => [ "dbi:SQLite:dbname=db/mixxi.db", "", "" ],
);

=head1 NAME

Mixxi::Model::URL - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Mixxi>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Mixxi::URL>

=head1 AUTHOR

Tatsuhiko Miyagawa,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
