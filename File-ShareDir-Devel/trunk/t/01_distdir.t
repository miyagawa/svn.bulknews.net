use strict;
use Test::Base;

plan 'no_plan';

use File::ShareDir::Devel 'Foo-Bar';
use File::ShareDir ':ALL';
use FindBin;

my $path = $FindBin::Bin;
   $path =~ s/t$/share/;

is dist_dir('Foo-Bar'), $path;

eval { dist_dir('Foo-Quox') };
like $@, qr/Failed to find share/;


