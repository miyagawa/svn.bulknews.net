use strict;
use Test::More tests => 4;

$ENV{MOD_PERL} = 1;
$INC{'Apache.pm'} = 1;		# dummy

package Apache;
sub request {
    bless {}, 'Mock::Apache';
}

package Mock::Apache;
my %pnotes;
sub pnotes {
    my($self, $key, $val) = @_;
    $pnotes{$key} = $val if $val;
    return $pnotes{$key};
}

package Printer;
use base qw(Apache::Singleton::Request);

package Printer::Device;
use base qw(Apache::Singleton::Request);

package main;
my $printer_a = Printer->instance;
my $printer_b = Printer->instance;

my $printer_d1 = Printer::Device->instance;
my $printer_d2 = Printer::Device->instance;

is "$printer_a", "$printer_b", 'same printer';
isnt "$printer_a", "$printer_d1", 'not same printer';
is "$printer_d1", "$printer_d2", 'same printer';

$printer_a->{foo} = 'bar';
is $printer_a->{foo}, $printer_b->{foo}, "attributes shared";



