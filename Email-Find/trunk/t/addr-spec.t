# $Id: addr-spec.t 429 2002-01-13 12:52:05Z miyagawa $
use strict;
use Test::More tests => 2;

BEGIN { use_ok 'Email::Find::addrspec' }
ok defined $Addr_spec_re;

