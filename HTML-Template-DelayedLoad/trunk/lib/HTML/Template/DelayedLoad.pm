package HTML::Template::DelayedLoad;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use HTML::Template;

sub new {
    my($class, %opt) = @_;
    bless {
	_dl_params => {},
	_dl_load   => [],
	%opt,
    }, $class;
}

sub param {
    my $self = shift;
    if (@_ == 0) {
	return keys %{$self->{_dl_params}};
    } elsif (@_ == 1) {
	return $self->{_dl_params}->{$_[0]};
    } elsif (@_ == 2) {
	$self->{_dl_params}->{$_[0]} = $_[1];
    } else {
	require Carp;
	Carp::croak('odd number of arguments for param()');
    }
}

sub load {
    my($self, $key, $value) = @_;
    unless (@_ == 3) {
	require Carp;
	Carp::croak('odd number of arguments for load()');
    }
    $self->{_dl_load} = [ $key, $value ];
}

sub output {
    my $self = shift;
    my %opt = map { $_ => $self->{$_} } grep { !/_dl_/ } keys %{$self};
    my $tmpl = HTML::Template->new(%opt, @{$self->{_dl_load}});
    $tmpl->param(%{$self->{_dl_params}});
    return $tmpl->output;
}

1;
__END__

=head1 NAME

HTML::Template::DelayedLoad - Delayed load of HTML with HTML::Template

=head1 SYNOPSIS

  use HTML::Template::DelayedLoad;

  $template = HTML::Template::DelayedLoad->new;
  $template->param(foo => 'barbar');

  # later ...
  $template->load(filename => 'foo.html');
  $html = $template->output;

=head1 DESCRIPTION

HTML::Template::DelayedLoad is a Proxy for HTML::Template, which
enables you to load HTML file B<after> various param() calls. It also
means that you can change your template HTML file exactly before its
output.

Actual loading of HTML is done in its output() method.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut
