use warnings;
use strict;

use Module::Build;

# -----------------------------------------------

my $class = Module::Build->subclass(code => <<'EOF');

sub ACTION_authortest
{
	my($self) = @_;

	$self->depends_on('build');
	$self->depends_on('manifest');
	$self->depends_on('distmeta');

	$self->test_files( qw< t xt/author > );
	$self->recursive_test_files(1);

	$self->depends_on('test');

	return;
}
EOF

$class -> new
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
	meta_merge =>
	{
		resources =>
		{
		'repository' => 'https://github.com/ronsavage/Genealogy-Gedcom-Date',
		},
	},
	requires =>
	{
		'DateTime' => 1.03,
		'DateTime::Infinite' => 1.03,
		'Moo' => 2.000001,
		'strict' => 0,
		'Try::Tiny' => 0.12,
		'Type::Tiny' => 1.000005,
		'warnings' => 0,
	},
	resources =>
	{
		'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy-Gedcom-Date',
		'license' => 'http://opensource.org/licenses/Artistic-2.0',
	},
) -> create_build_script();
