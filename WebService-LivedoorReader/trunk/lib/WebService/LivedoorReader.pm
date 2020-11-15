package WebService::LivedoorReader;
use strict;
our $VERSION = '0.01';

use URI;
use URI::QueryParam;
use WWW::Mechanize;

BEGIN {
    use Carp;

    our $HAVE_JSON_SYCK;
    eval { require JSON::Syck; $HAVE_JSON_SYCK = 1 };
    eval { require JSON } unless $HAVE_JSON_SYCK;

    Carp::croak("JSON::Syck or JSON required to use WebService::LivedoorReader") if $@;

    *parse_json =
        $HAVE_JSON_SYCK  ? sub { JSON::Syck::Load($_[1]) }
                         : sub { JSON::jsonToObj($_[1])  };
}

sub new {
    my($class, %param) = @_;

    my $self = bless { %param }, $class;
    $self->{mech} = WWW::Mechanize->new;

    return $self;
}

sub username    { shift->_var('username', @_) }
sub password    { shift->_var('password', @_) }

sub _var {
    my $self = shift;
    my $key  = shift;
    $self->{$key} = shift if @_;
    $self->{$key};
}

sub notify {
    my $self = shift;

    defined($self->username)
        or Carp::croak("username required");

    $self->{mech}->get("http://rpc.reader.livedoor.com/notify?user=" . $self->username);
    my $content = $self->{mech}->content;

    # copied from WebService/Bloglines.pm

    # |A|B| where A is the number of unread items
    $content =~ /\|([\-\d]+)|(.*)|/
	or $self->_die("Bad Response: $content");

    my($unread, $url) = ($1, $2);

    # A is -1 if the user email address is wrong.
    if ($unread == -1) {
	$self->_die("Bad username: $self->{username}");
    }

    # XXX should check $url?

    return $unread;
}

sub listsubs {
    my($self, $param) = @_;
    $self->_request("/api/subs", $param);
}

sub unread {
    my($self, $subid) = @_;
    my $data = $self->_request("/api/unread", { subscribe_id => $subid });
    $self->_request("/api/touch_all", { subscribe_id => $subid });
    $data;
}

sub _request {
    my($self, $method, $param) = @_;

    $self->login;

    my $uri = URI->new_abs($method, "http://reader.livedoor.com/");
    $uri->query_param(%$param) if $param;

    $self->{mech}->get($uri->as_string);

    return $self->parse_json($self->{mech}->content);
}

sub login {
    my $self = shift;

    return if $self->{__logined};

    local $^W; # input type="search" warning
    $self->{mech}->get("http://reader.livedoor.com/reader/");

    $self->{mech}->submit_form(
        form_name => 'loginForm',
        fields => {
            livedoor_id => $self->{username},
            password    => $self->{password},
        },
    );

    if ( $self->{mech}->content =~ /class="headcopy"/ ) {
        Carp::croak("Failed to login using username & password");
    }

    return $self->{__logined} = 1;
}

1;
__END__

=head1 NAME

WebService::LivedoorReader - API interface for Livedoor Reader

=head1 SYNOPSIS

  use WebService::LivedoorReader;

  my $reader = WebService::LivedoorReader->new(
      username => 'username',
      password => 'foobar',
  );

  my $count = $reader->notify();

  my $subscriptions = $reader->listsubs({ unread => 1 });

  for my $sub (@{$subscriptions}) {
      my $feed = $reader->unread($sub->{subscribe_id});
      my $title = $feed->{channel}->{title};
      for my $item (@{$feed->{items}}) {
          print $item->{title}, "\n";
      }
  }

=head1 DESCRIPTION

WebService::LivedoorReader is Perl API to access Livedoor Reader
backend using its JSON HTTP API. Note that this module's API is
premature and will be likely to change in the future, as livedoor
Reader's own API is updated.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<WebService::Bloglines>, L<JSON::Syck>, L<JSON>, L<http://reader.livedoor.com/>

=cut
