use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Exception::Handler',
    'VERSION_FROM' => 'lib/Exception/Handler.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
	Exception::Class => 0,
#	Sig::PackageScoped => 0,
	Error => 0,
    },
);
