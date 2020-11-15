use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'original',
    'VERSION_FROM' => 'lib/original.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'Devel::Symdump' => 0,
    },
);
