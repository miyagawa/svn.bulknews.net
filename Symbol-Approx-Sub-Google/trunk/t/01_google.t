use strict;
use Test::More tests => 1;

use Symbol::Approx::Sub
    xform => undef,
    match => 'Google';

$Symbol::Approx::Sub::Google::LicenseKey = $ENV{GOOGLE_KEY};

sub perl {
    return "foo";
}

SKIP: {
    skip 'no licesne key', 1 unless defined $ENV{GOOGLE_KEY};
    is perrl(), "foo", "perrl corrected to perl";
}



