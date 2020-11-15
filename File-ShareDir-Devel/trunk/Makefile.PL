use inc::Module::Install;

name 'File-ShareDir-Devel';
all_from 'lib/File/ShareDir/Devel.pm';

requires 'File::ShareDir';

use_test_base;
auto_include;
WriteAll;
