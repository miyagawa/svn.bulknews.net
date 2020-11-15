use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'htdiff',
    'VERSION_FROM' => 'htdiff', # finds $VERSION
    'PREREQ_PM' => {
	'HTML::Template' => 2.5,
	'Text::Diff' => 0.32,
    },
   'EXE_FILES' => [ 'htdiff' ],
);
