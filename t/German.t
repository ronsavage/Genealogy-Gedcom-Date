#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date;

use Test::Stream -V1;

# ------------------------------------------------

my(@candidates) =
(
	{
		date   => 'German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', kind => 'Date', type => 'German', month => 'Mär', year => '1950'}],
	},
	{
		date   => 'German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', kind => 'Date', type => 'German', month => 'Mär', year => '1950'}],
	},
	{
		date   => '21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', kind => 'Date', type => 'German', day => 21, month => 'Mär', year => '1950'}],
	},
	{
		date   => 'German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', kind => 'Date', type => 'German', day => 21, month => 'Mär', year => '1950'}],
	},
	{
		date   => 'Abt German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'ABT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'ABT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'ABT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'ABT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German 1950 VCHR',
		result => [{canonical => '@#dGERMAN@ 1950@ VCHR', bce => 'VCHR', flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'AFT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'AFT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'AFT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'AFT', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950 v.u.z.',
		result => [{canonical => '@#dGERMAN@ 1950 v.u.z', bce => 'v.u.z.', flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'BEF', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'BEF', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'BEF', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'BEF', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950 v.c.',
		result => [{canonical => '@#dGERMAN @1950 v.c.', bce => 'v.c.', flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bet German 1950 and 1956',
		result =>
		[
			{canonical => '@#dGERMAN@ 1950', flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{canonical => '1956', flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1950 and German 1956',
		result =>
		[
			{canonical => '1950', flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{canonical => '@#dGERMAN@ 1956', flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet German 1950 and German 1956',
		result =>
		[
			{canonical => '@#dGERMAN@ 1950', flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{canonical => '@#dGERMAN@ 1956', flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet Gregorian 1950 and German 1956',
		result =>
		[
			{canonical => '1950', flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{canonical => '@#dGERMAN@ 1956', flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet German 1950 and Gregorian 1956',
		result =>
		[
			{canonical => '@#dGERMAN@ 1950', flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{canonical => '1956', flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1501/01 and German 1510',
		result =>
		[
			{canonical => '@#dGERMAN@ 1501', flag => 'BET', kind => 'Date', suffix => '01', type => 'Gregorian', year => '1501'},
			{canonical => '@#dGERMAN@ 1510', flag => 'AND', kind => 'Date', type => 'German', year => '1510'},
		],
	},
	{
		date   => 'Bet German 1501 and 1510/02',
		result =>
		[
			{canonical => '@#dGERMAN@ 1501', flag => 'BET', kind => 'Date', type => 'German', year => '1501'},
			{canonical => '1510', flag => 'AND', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1510'},
		],
	},
	{
		date   => 'Cal German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'CAL', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'CAL', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'CAL', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'CAL', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 1950 v.chr.',
		result => [{canonical => '@#dGERMAN@ 1950 v.chr', bce => 'v.chr.', flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950 vuz',
		result => [{canonical => '@#dGERMAN@ 1950 vuz', bce => 'vuz', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950 vc',
		result => [{canonical => '@#dGERMAN@ 1950', bce => 'vc', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'FROM', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'FROM', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'From 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'FROM', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'FROM', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950 v.chr.',
		result => [{canonical => '@#dGERMAN@ 1950 v.chr', bce => 'v.chr.', flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'TO', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'To Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'TO', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German Mär.1950',
		result => [{canonical => '@#dGERMAN@ Mär.1950', flag => 'TO', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'TO', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 1950 vchr',
		result => [{canonical => '@#dGERMAN@ 1950 vchr', bce => 'vchr', flag => 'TO', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From 1901/02 to German 1903',
		result =>
		[
			{canonical => '1091', flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{canonical => '@#dGERMAN@ 1903', flag => 'TO', kind => 'Date', type => 'German', year => '1903'},
		],
	},
	{
		date   => 'From Gregorian 1901/02 to German 1903',
		result =>
		[
			{canonical => '1901', flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{canonical => '@#dGERMAN@ 1903', flag => 'TO', kind => 'Date', type => 'German', year => '1903'},
		],
	},
	{
		date   => 'From German 1901 to Gregorian 1903/04',
		result =>
		[
			{canonical => '@#dGERMAN@ 191', flag => 'FROM', kind => 'Date', type => 'German', year => '1901'},
			{canonical => '1903', flag => 'TO', kind => 'Date', suffix => '04', type => 'Gregorian', year => '1903'},
		],
	},
	{
		date   => 'From 1950 to German 1956',
		result =>
		[
			{canonical => '1950', flag => 'FROM', kind => 'Date', type => 'Gregorian', year => '1950'},
			{canonical => '@#dGERMAN@ 1956', flag => 'TO', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Int German 1950 (Approx)',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'INT', kind => 'Date', phrase => '(Approx)', type => 'German', year => '1950'}],
	},
	{
		date   => 'To 21.Mär.1950',
		result => [{canonical => '@#dGERMAN@ 21.Mär.1950', day => 21, flag => 'TO', kind => 'Date', month => 'Mär', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bet German 1501 and Julian 1510',
		result =>
		[
			{canonical => '@#dGERMAN@ 1501', flag => 'BET', kind => 'Date', type => 'German', year => '1501'},
			{canonical => '@#dJULIAN@ 1510', flag => 'AND', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From German 1501 to Julian 1510',
		result =>
		[
			{canonical => '@#dGERMAN@ 1501', flag => 'FROM', kind => 'Date', type => 'German', year => '1501'},
			{canonical => '@#dJULIAN@ 1510', flag => 'TO', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From Julian 1950 to German 1956',
		result =>
		[
			{canonical => '@#dJULIAN@ 1950', flag => 'FROM', kind => 'Date', type => 'Julian', year => '1950'},
			{canonical => '@#dGERMAN@ 1956', flag => 'TO', kind => 'Date', type => 'German', year => '1956'},
		],
	},
);

my($count)  = 0;
my($parser) = Genealogy::Gedcom::Date -> new;

my($date);
my($message);
my($result);

for my $item (@candidates)
{
	$count++;

	$result = $parser -> parse(date => $$item{date});

	#print STDERR "Result: \n", Dumper($result);

	is($result, $$item{result}, "$count. German: $$item{date}");
}

done_testing;
