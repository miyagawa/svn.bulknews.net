use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Symbol::Approx::Sub::Google',
    'VERSION_FROM' => 'lib/Symbol/Approx/Sub/Google.pm', # finds $VERSION
    'PREREQ_PM' => {
	'Test::More' => 0.32,
	'Symbol::Approx::Sub' => 2.00,
	'SOAP::Lite' => 0.52,
    },
);
