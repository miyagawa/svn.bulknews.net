use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Template::Plugin::Properties',
    'VERSION_FROM' => 'lib/Template/Plugin/Properties.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'Data::Properties' => 0.02,
	'Template' => 2.08,
	'IO::Scalar' => 0,
    },
);
