use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Mail::Address::Classify::mobile_jp',
    'VERSION_FROM' => 'lib/Mail/Address/Classify/mobile_jp.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0,
	Mail::Address::Classify => 0.01,
    },
);
