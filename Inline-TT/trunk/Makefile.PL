use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Inline::TT',
    'VERSION_FROM' => 'lib/Inline/TT.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'Template'   => 2.07,
	'Inline'     => 0.43,
    },
);
