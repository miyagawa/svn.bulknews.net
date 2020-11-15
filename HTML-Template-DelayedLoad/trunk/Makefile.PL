use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'HTML::Template::DelayedLoad',
    'VERSION_FROM' => 'lib/HTML/Template/DelayedLoad.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.18,
	HTML::Template => 2.4,
    },
);
