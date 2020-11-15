use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Net::DNS::IgnoreVerisign',
    'VERSION_FROM' => 'lib/Net/DNS/IgnoreVerisign.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
	Net::DNS => 0,
	Digest::MD5 => 0,
    },
);
