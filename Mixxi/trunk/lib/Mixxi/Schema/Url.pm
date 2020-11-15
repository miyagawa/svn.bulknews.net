package Mixxi::Schema::Url;

# Created by DBIx::Class::Schema::Loader v0.03008 @ 2006-11-02 02:00:14

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("url");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0, size => undef },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "alias",
  { data_type => "varchar", is_nullable => 0, size => 16 },
);
__PACKAGE__->set_primary_key("id");

use Number::RecordLocator;
my $encoder = Number::RecordLocator->new;

sub id_enc {
    my $self = shift;
    $encoder->encode($self->id);
}

sub to_id {
    my($class, $enc) = @_;
    $encoder->decode($enc);
}

sub canon_path {
    my $self = shift;

    if ($self->alias) {
        return $self->alias;
    } else {
        return "u/" . $self->id_enc;
    }
}

1;

