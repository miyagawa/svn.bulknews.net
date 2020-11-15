use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Apache::Session::Generate::ModUsertrack',
    'VERSION_FROM' => 'lib/Apache/Session/Generate/ModUsertrack.pm', # finds $VERSION
    'PREREQ_PM' => {
	Apache::Session => 1.53,
	Test::More      => 0.18,
	CGI::Cookie     => 0,
    },
);
