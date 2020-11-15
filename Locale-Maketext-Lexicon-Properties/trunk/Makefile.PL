use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Locale::Maketext::Lexicon::Properties',
    'VERSION_FROM' => 'lib/Locale/Maketext/Lexicon/Properties.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'Locale::Maketext::Lexicon' => 0.08,
	'Data::Properties' => 0.02,
	'IO::ScalarArray' => 2.103,
    },
);
