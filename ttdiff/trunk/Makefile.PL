use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'ttdiff',
    'VERSION_FROM' => 'ttdiff', # finds $VERSION
    'PREREQ_PM' => {
	'Template' => 2.07,
	'Text::Diff' => 0.32,
    },
   'EXE_FILES' => [ 'ttdiff' ],
);
