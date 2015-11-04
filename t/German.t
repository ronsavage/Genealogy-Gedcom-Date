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
		result => [{kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Dez.1950',
		result => [{kind => 'Date', type => 'German', month => 'Dez', year => '1950'}],
	},
	{
		date   => 'German Dez.1950',
		result => [{kind => 'Date', type => 'German', month => 'Dez', year => '1950'}],
	},
	{
		date   => '21.Dez.1950',
		result => [{kind => 'Date', type => 'German', day => 21, month => 'Dez', year => '1950'}],
	},
	{
		date   => 'German 21.Dez.1950',
		result => [{kind => 'Date', type => 'German', day => 21, month => 'Dez', year => '1950'}],
	},
	{
		date   => 'Abt German 1950',
		result => [{flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt Dez.1950',
		result => [{flag => 'ABT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German Dez.1950',
		result => [{flag => 'ABT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt 21.Dez.1950',
		result => [{day => 21, flag => 'ABT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German 21.Dez.1950',
		result => [{day => 21, flag => 'ABT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German 1950 VCHR',
		result => [{bce => 'VCHR', flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950',
		result => [{flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft Dez.1950',
		result => [{flag => 'AFT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German Dez.1950',
		result => [{flag => 'AFT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft 21.Dez.1950',
		result => [{day => 21, flag => 'AFT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 21.Dez.1950',
		result => [{day => 21, flag => 'AFT', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950 vchr',
		result => [{bce => 'vchr', flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950',
		result => [{flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef Dez.1950',
		result => [{flag => 'BEF', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German Dez.1950',
		result => [{flag => 'BEF', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef 21.Dez.1950',
		result => [{day => 21, flag => 'BEF', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 21.Dez.1950',
		result => [{day => 21, flag => 'BEF', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950 v.c.',
		result => [{bce => 'v.c.', flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bet German 1950 and 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1950 and German 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet German 1950 and German 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet Gregorian 1950 and German 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Bet German 1950 and Gregorian 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'German', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1501/01 and German 1510',
		result =>
		[
			{flag => 'BET', kind => 'Date', suffix => '01', type => 'Gregorian', year => '1501'},
			{flag => 'AND', kind => 'Date', type => 'German', year => '1510'},
		],
	},
	{
		date   => 'Bet German 1501 and 1510/02',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'German', year => '1501'},
			{flag => 'AND', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1510'},
		],
	},
	{
		date   => 'Cal German 1950',
		result => [{flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal Dez.1950',
		result => [{flag => 'CAL', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German Dez.1950',
		result => [{flag => 'CAL', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal 21.Dez.1950',
		result => [{day => 21, flag => 'CAL', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 21.Dez.1950',
		result => [{day => 21, flag => 'CAL', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 1950 v.chr.',
		result => [{bce => 'v.chr.', flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950',
		result => [{flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est Dez.1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Dez.1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est 21.Dez.1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Dez.1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950 vc',
		result => [{bce => 'vc', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950',
		result => [{flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est Dez.1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Dez.1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est 21.Dez.1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Dez.1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950 vc',
		result => [{bce => 'vc', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950',
		result => [{flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From Dez.1950',
		result => [{flag => 'FROM', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German Dez.1950',
		result => [{flag => 'FROM', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'From 21.Dez.1950',
		result => [{day => 21, flag => 'FROM', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 21.Dez.1950',
		result => [{day => 21, flag => 'FROM', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950 v.chr.',
		result => [{bce => 'v.chr.', flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 1950',
		result => [{flag => 'TO', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'To Dez.1950',
		result => [{flag => 'TO', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German Dez.1950',
		result => [{flag => 'TO', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 21.Dez.1950',
		result => [{day => 21, flag => 'TO', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'To German 1950 vchr',
		result => [{bce => 'vchr', flag => 'TO', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From 1901/02 to German 1903',
		result =>
		[
			{flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{flag => 'TO', kind => 'Date', type => 'German', year => '1903'},
		],
	},
	{
		date   => 'From Gregorian 1901/02 to German 1903',
		result =>
		[
			{flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{flag => 'TO', kind => 'Date', type => 'German', year => '1903'},
		],
	},
	{
		date   => 'From German 1901 to Gregorian 1903/04',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'German', year => '1901'},
			{flag => 'TO', kind => 'Date', suffix => '04', type => 'Gregorian', year => '1903'},
		],
	},
	{
		date   => 'From 1950 to German 1956',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'TO', kind => 'Date', type => 'German', year => '1956'},
		],
	},
	{
		date   => 'Int German 1950 (Approx)',
		result => [{flag => 'INT', kind => 'Date', phrase => '(Approx)', type => 'German', year => '1950'}],
	},
	{
		date   => 'To 21.Dez.1950',
		result => [{day => 21, flag => 'TO', kind => 'Date', month => 'Dez', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bet German 1501 and Julian 1510',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'German', year => '1501'},
			{flag => 'AND', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From German 1501 to Julian 1510',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'German', year => '1501'},
			{flag => 'TO', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From Julian 1950 to German 1956',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'Julian', year => '1950'},
			{flag => 'TO', kind => 'Date', type => 'German', year => '1956'},
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
