use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Filter::Pyuuta',
    'VERSION_FROM' => 'lib/Filter/Pyuuta.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.18,
	Filter::Simple => 0.61,
    },
);
