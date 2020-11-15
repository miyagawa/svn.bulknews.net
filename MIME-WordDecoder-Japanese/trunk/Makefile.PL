use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'MIME::WordDecoder::Japanese',
    'VERSION_FROM' => 'lib/MIME/WordDecoder/Japanese.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More  => 0.18,
	MIME::Tools => 5.411,
	Jcode       => 0.75,
    },
);
