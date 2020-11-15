package Net::YahooMessenger::IRCGW::EventHandler;
use strict;

use Net::YahooMessenger::EventHandler;
use base qw(Net::YahooMessenger::EventHandler);

use Jcode;
use Net::YahooMessenger::IRCGW;

sub gw { Net::YahooMessenger::IRCGW->instance }

sub ChangeState {
    my($self, $event) = @_;
    $self->gw->conn->me(
	'#' . $event->from, Jcode->new($event->body, 'sjis')->jis,
    );
}

sub GoesOnline {
    my($self, $event) = @_;
    $self->gw->join_channel($event->from, '[YM] Online');
}

sub GoesOffline {
    my($self, $event) = @_;
    $self->gw->part_channel($event->from);
}

sub ReceiveMessage {
    my($self, $event) = @_;
    my $msg = Jcode->new($event->body, 'sjis')->jis;
    $msg =~ s/^<font.*?>//;
    $self->gw->conn->privmsg('#' . $event->from, $_) for split /\n/, $msg;
}

1;
