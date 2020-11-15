use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'WebService::LivedoorReader',
    'VERSION_FROM' => 'lib/WebService/LivedoorReader.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
    },
);
