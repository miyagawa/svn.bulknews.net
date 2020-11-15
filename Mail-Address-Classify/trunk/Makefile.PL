use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Mail::Address::Classify',
    'VERSION_FROM' => 'lib/Mail/Address/Classify.pm', # finds $VERSION
    'PREREQ_PM' => {
	Mail::Address => 1.40,
	Test::More => 0,
    },
);
