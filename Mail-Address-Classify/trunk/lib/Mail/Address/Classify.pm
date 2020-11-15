package Mail::Address::Classify;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use Mail::Address;
use vars qw($AUTOLOAD);

sub _croak {
    require Carp;
    Carp::croak(@_);
}

sub new {
    my($class, $addr) = @_;
    unless (UNIVERSAL::isa($addr, 'Mail::Address')) {
	$addr = (Mail::Address->parse($addr))[0] or _croak "Can't make Mail::Address instance";
    }
    bless {
	__loaded => {},
	email => $addr,
    }, $class;
}

sub belongs {
    my($self, $module) = @_;
    unless ($self->{__loaded}->{$module}) {
	$self->_load_module($module);
    }
    my $class = "Mail::Address::Classify::$module";
    return $class->is_valid($self);
}

sub _load_module {
    my($self, $module) = @_;
    eval qq{require Mail::Address::Classify::$module};
    if ($@ && $@ !~ /locate/) {
	_croak $@;
    }
    $self->{__loaded}->{$module} = 1;
}

sub AUTOLOAD {
    my $self = shift;
    (my $meth = $AUTOLOAD) =~ s/.*:://;
    $self->{email}->$meth(@_);
}

1;
__END__

=head1 NAME

Mail::Address::Classify - Mail address classification framework

=head1 SYNOPSIS

  use Mail::Address::Classify;

  my $addr = Mail::Address::Classify->new('foo@example.com');
  if ($addr->belongs('mobile_jp')) {
      print "Address: ", $addr->address, " is mobile one in Japan";
  }

  # your own classification
  package Mail::Address::Classify::mailer_daemon;

  sub is_valid {
      my($class, $addr) = @_;
      return uc($addr->user) eq 'MAILER-DAEMON';
  }

  package main;
  my $addr = Mail::Address::Classify->new('MAILER-DAEMON@example.com');
  if ($addr->belongs('mailer_daemon')) {
      print "Address: ", $addr->format, " is mailer-daemon";
  }

=head1 DESCRIPTION

Mail::Address::Classify is a (pluggable) lightweight framework for
Email address classification. It can be quite useful in cases like
validating if an address

=over 4

=item *

is a free mail (on the web) or not

=item *

is a mobile (cellular) mail or not

=back

Mail::Address::Classify is a simple framework, so it cannot be used
without any pluggable module for the classification. Currently
distributed classification is C<mobile_jp>.

I hope we will have more implementations soon. See
L<Mail::Address::Classify::mobile_jp> and do search on CPAN for more
modules.

=head1 METHODS

=over 4

=item new

  $addr = Mail::Address::Classify->new('foo@example.com');
  $addr = Mail::Address::Classify->new('foo <foo@example.com>');
  $addr = Mail::Address::Classify->new(
       Mail::Address->new('foo', 'foo@example.com'),
  );

constructs Mail::Address::Classify instance.

Mail::Address::Classify delegates methods to Mail::Address, so you can
call any instance methods of Mail::Address on the object like:

  my $output = $addr->format;

=item belongs

  if ($addr->belongs('foo')) { }

Suppose you have Mail::Address::Classify::foo module, you can call
C<belongs> method to Mail::Address::Classify instance with C<foo>
argument. This will result in the method call

  Mail::Address::Classify::foo->is_valid($addr);

where C<$addr> is the object. So what you should do is define your own
C<is_valid> class method:

  package Mail::Address::Classify::foo;

  sub is_valid {
      my($class, $addr) = @_;
      # do some stuff, and returns if $addr belongs to 'foo'
  }

XXX should I name this method C<belongs_to>?

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mail::Address>, L<Mail::Address::Classify::mobile_jp>

=cut
