use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'irc-yahoo',
    'VERSION_FROM' => 'irc-yahoo', # finds $VERSION
    'dist'  => { COMPRESS => 'gzip', SUFFIX => 'gz' },
    'EXE_FILES' => [ 'irc-yahoo' ], # scripts to install
    'PREREQ_PM' => {
	'Net::YahooMessenger' => 0.09,
	'Net::IRC' => 0,
    },
);

