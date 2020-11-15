use HTTP::ProxyPAC;
use FindBin;
use Test::More tests => 13;
use URI;

my $path = "$FindBin::Bin/proxy.pac";

# test via path
my $pac = HTTP::ProxyPAC->new($path);

my $res = $pac->find_proxy("http://www.google.com/");
ok $res->direct;
ok !$res->proxy;

$res = $pac->find_proxy("http://intra.example.com/");
ok !$res->direct;
is $res->proxy->host_port, 'proxy.example.jp:8080';

@res = $pac->find_proxy("http://intra.example.com/");
is scalar @res, 2;
is $res[0]->proxy->host_port, 'proxy.example.jp:8080';
ok $res[1]->direct;

$res = $pac->find_proxy("http://localhost/");
ok $res->direct;

$res = $pac->find_proxy("http://192.168.108.3/");
ok !$res->direct;
is $res->proxy->host_port, 'proxy.example.jp:8080';

# test via URL
SKIP: {
    skip 'DEV only', 1 unless $ENV{HTTP_PROXYPAC_DEV};
    $pac = HTTP::ProxyPAC->new( URI->new("http://localhost/~miyagawa/proxy.pac") );
    $res = $pac->find_proxy("http://www.google.com/");
    ok $res->direct;
}

# test via scalar ref
open my $fh, $path or die "$path: $!";
my $code = join '', <$fh>;

$pac = HTTP::ProxyPAC->new(\$code);
$res = $pac->find_proxy("http://www.google.com/");
ok $res->direct;

# test via filehandle
open my $fh2, $path or die "$path: $!";

$pac = HTTP::ProxyPAC->new($fh2);
$res = $pac->find_proxy("http://www.google.com/");
ok $res->direct;
