use Module::Build;

Module::Build -> new
(
	module_name    => 'Genealogy::Gedcom::Date',
	license        => 'artistic_2',
	dist_abstract  => 'Parse GEDCOM dates',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		Test::More => 0.98,
#		Test::Pod  => 1.45, # Make it optional. See t/pod.t
	},
	configure_requires =>
	{
		Module::Build => 0.3800,
	},
	requires =>
	{
		DateTime           => 1.03,
		DateTime::Infinite => 1.03,
		Hash::FieldHash    => 0.14,
		strict             => 0,
		Try::Tiny          => 0.12,
		warnings           => 0,
	},
) -> create_build_script();
