package MT::Plugin::YMStatus;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use MT::Template::Context;
use Net::YahooMessenger;

BEGIN {
    for my $constant (qw(CUSTOM_STATUS IM_AVAILABLE SLEEP)) {
	no strict 'refs';
	*$constant = \&{"Net::YahooMessenger::Buddy::$constant"};
    }
}

MT::Template::Context->add_container_tag(YMStatus => \&YMStatus);
MT::Template::Context->add_tag(YMStatusMessage => \&YMStatusMessage);
MT::Template::Context->add_tag(YMBuddyName => \&YMBuddyName);

_add_conditional_tag($_) for qw(YMIfOnline YMIfOffline YMIfCustomStatus 
				YMIfAvailable YMIfBusy YMIfSleep);

sub _add_conditional_tag {
    my $name = shift;
    # XXX add_conditional_tag doesn't work ...
    MT::Template::Context->add_container_tag(
        $name => sub {
	    my $ctx = shift;
	    return $ctx->stash($name) ? _build_tokens($ctx) : '';
	},
    );
}
       
sub YMStatus {
    my($ctx, $args) = @_;
    my %msger_args = map { $_ => $args->{$_} } 
        grep { exists $args->{$_} } qw(id password hostname);
    my $msger = Net::YahooMessenger->new(%msger_args);
    $msger->login or return $ctx->error("YM login failed for $args->{id}");

    # login succesdful, get buddy information
    my $buddy = $msger->get_buddy_by_name($args->{target})
	or return $ctx->error("Don't know buddy $args->{target}. ".
			      "Register to $args->{id}'s friends manually");

    # Store variables to Stash
    $ctx->stash(YMIfOnline => $buddy->is_online);
    $ctx->stash(YMIfOffline => !$buddy->is_online);

    my $status = $buddy->status;
    $ctx->stash(YMIfCustomStatus => $status == CUSTOM_STATUS);
    $ctx->stash(YMIfAvailable => ($status == IM_AVAILABLE));
    $ctx->stash(YMIfBusy => ($status != IM_AVAILABLE && $status < CUSTOM_STATUS));
    $ctx->stash(YMIfSleep => ($status == SLEEP));

    $ctx->stash(YMStatusMessage => $buddy->get_status_message);
    $ctx->stash(YMBuddyName => $buddy->name);

    _build_tokens($ctx);
}

sub _build_tokens {
    my $ctx = shift;
    my $tokens  = $ctx->stash('tokens');
    my $builder = $ctx->stash('builder');

    defined(my $out = $builder->build($ctx, $tokens))
	or return $ctx->error($builder->errstr);
    return $out;
}

sub YMStatusMessage { $_[0]->stash('YMStatusMessage') || '' }
sub YMBuddyName     { $_[0]->stash('YMBuddyName') || '' }

1;

__END__

=head1 NAME 

mt-ymstatus - your Yahoo! Messenger status on MT

=head1 SYNOPSIS

  <MTYMStatus id="tracker_id" password="blahblah"
     target="your_real_id" hostname="cs.yahoo.co.jp">
  YM status for <$MTYMBuddyName$>: 
  <MTYMIfOnline>online
  <MTYMIfCustomStatus> - <$MTYMStatusMessage$></MTYMIfCustomStatus>
  </MTYMIfOnline>
  <MTYMIfOffline>offline</MTYMIfOffline>
  </MTYMStatus>

Note that hostname attribute is for .yahoo.co.jp, so you don't need it
if you use .yahoo.com service.

=head1 DESCRIPTION

C<mt-ymstatus> is a MT plugin which allows you to publish your Yahoo! 
Messenger status (including custom message) on MovableType Blogs.

Note that you need another Yahoo! Messenger account (indicated as
I<tracker_id> in synopsis) than yours (I<target>) to get your YM status.

=head1 TAGS

=over 4

=item MTYMStatus

container tag to generate ymstatus content.

=item MTYMIfOnline, MTYMIfOffline

conditional container tag to show if you're online or offline.

=item MTYMIfCustomStatus

conditional container tag to show if you use custom status or not.

=item MTYMIfAvailable, MTYMIfBusy, MTYMIfSleep

conditional container tag to show your status.

=item MTYMStatusMessage

your YM status message, including custom status.

=item MTYMBuddyName

your YM account.

=back

=head1 REQUIREMENTS

This plugin requires following CPAN modules installed.

=over 4

=item *

Net::YahooMessenger

=back

If you use this plugin in Japanese blogs, you need C<mt-jcode> to
convert character encoding at:

http://bulknews.net/lib/archives/

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 SEE ALSO

L<Net::YahooMessenger>, C<mt-jcode>, L<MT>

=cut
