use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		AUTHOR   => 'Ron Savage (ron@savage.net.au)',
		ABSTRACT => 'Parse GEDCOM dates',
	) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Genealogy-Gedcom-Date-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Genealogy-Gedcom-Date',
	NAME      => 'Genealogy::Gedcom::Date',
	LICENSE   => 'artistic_2',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		DateTime           => 1.03,
		DateTime::Infinite => 1.03,
		Hash::FieldHash    => 0.14,
		strict             => 0,
		Test::More         => 0.98,
#		Test::Pod          => 1.45, # Make it optional. See t/pod.t
		Try::Tiny          => 0.12,
		warnings           => 0,
	},
	VERSION_FROM => 'lib/Genealogy/Gedcom/Date.pm',
);
