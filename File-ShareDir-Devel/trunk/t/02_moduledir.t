use strict;
use Test::Base;

plan 'no_plan';

use File::ShareDir::Devel 'File-SharDir-Devel';
use File::ShareDir ':ALL';

like module_dir('File::ShareDir::Devel'), qr/share$/;
like module_dir('File::ShareDir'), qr/auto/;



