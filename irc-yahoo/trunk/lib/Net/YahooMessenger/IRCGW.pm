package Net::YahooMessenger::IRCGW;
use strict;

use Jcode;
use Net::IRC;
use Net::YahooMessenger::IRCGW::EventHandler;

use Class::Singleton;
use base qw(Class::Singleton);

sub croak { require Carp; Carp::croak(@_) }

sub _new_instance {
    my($class, $conf) = @_;
    bless {
	_conf => $conf,
	ym    => undef,
	irc   => undef,
	conn  => undef,
    }, $class;
}

sub conf {
    my($self, $name) = @_;
    return $self->{_conf}->{$name};
}

sub irc_conn {
    my($self, $name) = @_;
    return $self->{irc_con}->{$name};
}

sub ym   { shift->{ym} }
sub irc  { shift->{irc} }
sub conn { shift->{conn} }

sub start {
    my $self = shift;
    $self->ym_init;
    $self->irc_init;
    $self->ym_login;
    $self->do_loop while 1;
}

sub ym_init {
    my $self = shift;
    my $msger = Net::YahooMessenger->new(
	id       => $self->conf('login_id'),
	password => $self->conf('password'),
	pre_login_url     => 'http://edit.my.yahoo.co.jp/config/',
	socket_server_url => 'http://update.messenger.yahoo.co.jp/servers.html',
    );
    $msger->set_event_handler(Net::YahooMessenger::IRCGW::EventHandler->new);
    $self->{ym} = $msger;
}

sub irc_init {
    my $self = shift;
    my $irc = Net::IRC->new;
    my $conn = $irc->newconn(
	Server => $self->conf('irc_server'),
	Port   => $self->conf('irc_port'),
	Nick   => $self->conf('irc_nick'),
	Ircname => 'irc-yahoo',
    );
    $self->set_irc_handler($conn);
    $self->{irc}  = $irc;
    $self->{conn} = $conn;
}

sub ym_login {
    my $self = shift;
    $self->ym->login or croak "YM login fail!";

    # intialize IRC connections for Yahoo! Messenger ID
    my @buddies = grep $_->is_online, $self->ym->buddy_list;
    $self->join_channel($_->name, $_->get_status_message) for @buddies;
}

sub join_channel {
    my($self, $name, $status) = @_;
    $self->conn->join('#' . $name);
    $self->conn->me('#' . $name, Jcode->new($status, 'sjis')->jis);
}

sub part_channel {
    my($self, $name) = @_;
    $self->conn->part('#' . $name);
}

sub set_irc_handler {
    my($self, $conn) = @_;

    # privmsg => YM
    $conn->add_handler(
	public => sub {
	    my($irc_conn, $event) = @_;
	    return unless $self->ircauth($event);
	    my($to)  = $event->to;
	    $to =~ s/^#//;
	    my($msg) = $event->args;
	    $self->ym->send($to, Jcode->new($msg, 'jis')->sjis);
	},
    );

    # CTCP action => YM status
    $conn->add_handler(
	caction => sub {
	    my($irc_conn, $event) = @_;
	    return unless $self->ircauth($event);
	    my($msg) = $event->args;
	    $self->ym->change_state(0, Jcode->new($msg, 'jis')->sjis);
	},
    );
}

sub ircauth {
    my($self, $event) = @_;
    return $event->nick eq $self->conf('irc_yournick');
}

sub do_loop {
    my $self = shift;
    $_->do_one_loop for ($self->ym, $self->irc);
}

1;
