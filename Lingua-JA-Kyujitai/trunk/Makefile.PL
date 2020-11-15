use inc::Module::Install;
name 'Lingua-JA-Kyujitai';
all_from 'lib/Lingua/JA/Kyujitai.pm';
requires 'Encode';
build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
