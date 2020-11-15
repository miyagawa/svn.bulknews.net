use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Mail::ListDetector::Detector::Fml',
    'VERSION_FROM' => 'lib/Mail/ListDetector/Detector/Fml.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
	Mail::ListDetector => 0.18,
	URI => 0,
    },
);
