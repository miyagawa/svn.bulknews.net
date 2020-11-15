use strict;
use Test::More tests => 6;
use Digest::MD5 qw(md5_hex);
use Net::DNS::IgnoreVerisign;

my $nonexistent = md5_hex(rand(1000) . {} . $$ . time) . "blahblah";

for my $tld (qw(net com jp)) {
    my $res = Net::DNS::Resolver->new();
    my $ans = $res->search("$nonexistent.$tld");

    is $ans, undef, "$nonexistent.$tld is not existent";
}

my $existent = "cpan";
for my $tld (qw(net com org)) {
    my $res = Net::DNS::Resolver->new();
    my $ans = $res->search("$existent.$tld");

    ok(defined($ans), "$existent.$tld is existent");
}
