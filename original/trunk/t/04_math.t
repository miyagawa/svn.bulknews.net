use strict;
use Test::More 'no_plan';

use lib 't/lib';

use Three;
is( Three->value, 3 );

require Three::AddOne;
import Three::AddOne;
is( Three->value, 4 );

require Three::AddTwo;
import Three::AddTwo;
is( Three->value, 6 );

require Three::AddTwo;
import Three::AddTwo;
is( Three->value, 6 );
