use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Apache::Session::Generate::ModUniqueId',
    'VERSION_FROM' => 'lib/Apache/Session/Generate/ModUniqueId.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0,
	Apache::Session => 1.53,
    },
);
