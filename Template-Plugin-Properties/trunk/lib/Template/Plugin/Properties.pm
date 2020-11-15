package Template::Plugin::Properties;

use strict;
use vars qw($VERSION);
$VERSION = 0.02;

require Template::Plugin;
use base qw(Template::Plugin);

use Data::Properties;
use FileHandle;
use IO::Scalar;

use vars qw($DYNAMIC $FILTER_NAME);
$DYNAMIC = 1;
$FILTER_NAME = 'parse_property';

sub croak { require Carp; Carp::croak(@_); }

sub new {
    my($class, $context, $filename, $params) = @_;
    my $props = Data::Properties->new;
    if ($filename) {
	my $handle = FileHandle->new($filename) or croak("$filename: $!");
	$props->load($handle);
    }
    bless { _props => $props }, $class;
}

sub props { shift->{_props} }

sub get {
    my $self = shift;
    $self->props->get_property(@_);
}

sub set {
    my($self, $param) = @_;
    $self->props->set_property(%$param);
    return; # set_property() returns 1
}

sub names {
    my $self = shift;
    return $self->props->property_names;
}

sub parse {
    my($self, $text) = @_;
    my $handle = IO::Scalar->new(\$text);
    $self->props->load($handle);
    return;
}

1;
__END__

=head1 NAME

Template::Plugin::Properties - TT Plugin to read Data::Properties file

=head1 SYNOPSIS

  [% USE props = Properties('/path/to/properties') %]
  [% FOREACH key = props.names %]
    [% key %] is [% props.get(key) %]
  [% END %]

  # get can accept default
  name is [% props.get('name', 'name (defaut)') %]

  # construct without file is ok
  [% USE props = Properties %]
  [% props.set('foo.bar' => 'baz') %]
  foo.bar = [% props.get('foo.bar') %]

=head1 DESCRIPTION

Template::Plugin::Properties is a TT plugin which allows you to read
property variables from inside templates using Data::Properties.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Data::Properties>, L<Template::Plugin::Datafile>

=cut
