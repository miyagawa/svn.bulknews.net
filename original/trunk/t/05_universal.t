use strict;
use Test::More 'no_plan';

use lib 't/lib';

use Three;
use Three::AddThree;

is( Three->value, 6 );
