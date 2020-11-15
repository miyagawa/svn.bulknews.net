use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'HTTP::ProxyPAC',
    'VERSION_FROM' => 'lib/HTTP/ProxyPAC.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
        LWP => 5.6,
        JavaScript => 0,
        Scalar::Util => 0,
        URI => 1.3,
    },
);
