use warnings;
use strict;

use Module::Build;

Module::Build -> new
(
	module_name    => 'Genealogy::Gedcom::Date',
	license        => 'artistic_2',
	dist_abstract  => 'Parse GEDCOM dates',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		'Test::More' => 1.001014,
		'Test::Pod' => 1.48,
	},
	configure_requires =>
	{
		'Module::Build' => 0.4211,
	},
	requires =>
	{
		'DateTime' => 1.03,
		'DateTime::Infinite' => 1.03,
		'Hash::FieldHash' => 0.14,
		'strict' => 0,
		'Try::Tiny' => 0.12,
		'warnings' => 0,
	},
) -> create_build_script();
