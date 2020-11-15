use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'CGI::BufferedHeader',
    'VERSION_FROM' => 'lib/CGI/BufferedHeader.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.18,
	Class::Delegation => 1.00,
	# CGI => 0,
    },
);
