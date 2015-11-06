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
		date   => 'French r 1950',
		result => [{kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Vend 1950',
		result => [{kind => 'Date', type => 'French r', month => 'Vend', year => '1950'}],
	},
	{
		date   => 'French r Vend 1950',
		result => [{kind => 'Date', type => 'French r', month => 'Vend', year => '1950'}],
	},
	{
		date   => '21 Vend 1950',
		result => [{kind => 'Date', type => 'French r', day => 21, month => 'Vend', year => '1950'}],
	},
	{
		date   => 'French r 21 Vend 1950',
		result => [{kind => 'Date', type => 'French r', day => 21, month => 'Vend', year => '1950'}],
	},
	{
		date   => 'Abt French r 1950',
		result => [{flag => 'ABT', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Abt Vend 1950',
		result => [{flag => 'ABT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Abt French r Vend 1950',
		result => [{flag => 'ABT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Abt 21 Vend 1950',
		result => [{day => 21, flag => 'ABT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Abt French r 21 Vend 1950',
		result => [{day => 21, flag => 'ABT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Abt French r 1950 BC',
		result => [{bce => 'BC', flag => 'ABT', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft French r 1950',
		result => [{flag => 'AFT', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft Vend 1950',
		result => [{flag => 'AFT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft French r Vend 1950',
		result => [{flag => 'AFT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft 21 Vend 1950',
		result => [{day => 21, flag => 'AFT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft French r 21 Vend 1950',
		result => [{day => 21, flag => 'AFT', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Aft French r 1950 bc',
		result => [{bce => 'bc', flag => 'AFT', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef French r 1950',
		result => [{flag => 'BEF', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef Vend 1950',
		result => [{flag => 'BEF', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef French r Vend 1950',
		result => [{flag => 'BEF', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef 21 Vend 1950',
		result => [{day => 21, flag => 'BEF', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef French r 21 Vend 1950',
		result => [{day => 21, flag => 'BEF', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bef French r 1950 BCE',
		result => [{bce => 'BCE', flag => 'BEF', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bet French r 1950 and 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'French r', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1950 and French r 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'French r', year => '1956'},
		],
	},
	{
		date   => 'Bet French r 1950 and French r 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'French r', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'French r', year => '1956'},
		],
	},
	{
		date   => 'Bet Gregorian 1950 and French r 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'French r', year => '1956'},
		],
	},
	{
		date   => 'Bet French r 1950 and Gregorian 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'French r', year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'Gregorian', year => '1956'},
		],
	},
	{
		date   => 'Bet 1501/01 and French r 1510',
		result =>
		[
			{flag => 'BET', kind => 'Date', suffix => '01', type => 'Gregorian', year => '1501'},
			{flag => 'AND', kind => 'Date', type => 'French r', year => '1510'},
		],
	},
	{
		date   => 'Bet French r 1501 and 1510/02',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'French r', year => '1501'},
			{flag => 'AND', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1510'},
		],
	},
	{
		date   => 'Cal French r 1950',
		result => [{flag => 'CAL', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Cal Vend 1950',
		result => [{flag => 'CAL', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Cal French r Vend 1950',
		result => [{flag => 'CAL', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Cal 21 Vend 1950',
		result => [{day => 21, flag => 'CAL', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Cal French r 21 Vend 1950',
		result => [{day => 21, flag => 'CAL', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Cal French r 1950 bce',
		result => [{bce => 'bce', flag => 'CAL', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 1950',
		result => [{flag => 'EST', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est Vend 1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r Vend 1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est 21 Vend 1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 21 Vend 1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 1950 bc',
		result => [{bce => 'bc', flag => 'EST', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 1950',
		result => [{flag => 'EST', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est Vend 1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r Vend 1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est 21 Vend 1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 21 Vend 1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Est French r 1950 bc',
		result => [{bce => 'bc', flag => 'EST', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From French r 1950',
		result => [{flag => 'FROM', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From Vend 1950',
		result => [{flag => 'FROM', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From French r Vend 1950',
		result => [{flag => 'FROM', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From 21 Vend 1950',
		result => [{day => 21, flag => 'FROM', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From French r 21 Vend 1950',
		result => [{day => 21, flag => 'FROM', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From French r 1950 bc',
		result => [{bce => 'bc', flag => 'FROM', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To French r 1950',
		result => [{flag => 'TO', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To Vend 1950',
		result => [{flag => 'TO', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To French r Vend 1950',
		result => [{flag => 'TO', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To French r 21 Vend 1950',
		result => [{day => 21, flag => 'TO', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To French r 1950 bc',
		result => [{bce => 'bc', flag => 'TO', kind => 'Date', type => 'French r', year => '1950'}],
	},
	{
		date   => 'From 1901/02 to French r 1903',
		result =>
		[
			{flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{flag => 'TO', kind => 'Date', type => 'French r', year => '1903'},
		],
	},
	{
		date   => 'From Gregorian 1901/02 to French r 1903',
		result =>
		[
			{flag => 'FROM', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1901'},
			{flag => 'TO', kind => 'Date', type => 'French r', year => '1903'},
		],
	},
	{
		date   => 'From French r 1901 to Gregorian 1903/04',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'French r', year => '1901'},
			{flag => 'TO', kind => 'Date', suffix => '04', type => 'Gregorian', year => '1903'},
		],
	},
	{
		date   => 'From 1950 to French r 1956',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'Gregorian', year => '1950'},
			{flag => 'TO', kind => 'Date', type => 'French r', year => '1956'},
		],
	},
	{
		date   => 'Int French r 1950 (Approx)',
		result => [{flag => 'INT', kind => 'Date', phrase => '(Approx)', type => 'French r', year => '1950'}],
	},
	{
		date   => 'To 21 Vend 1950',
		result => [{day => 21, flag => 'TO', kind => 'Date', month => 'Vend', type => 'French r', year => '1950'}],
	},
	{
		date   => 'Bet French r 1501 and Julian 1510',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'French r', year => '1501'},
			{flag => 'AND', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From French r 1501 to Julian 1510',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'French r', year => '1501'},
			{flag => 'TO', kind => 'Date', type => 'Julian', year => '1510'},
		],
	},
	{
		date   => 'From Julian 1950 to French r 1956',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'Julian', year => '1950'},
			{flag => 'TO', kind => 'Date', type => 'French r', year => '1956'},
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

	is($result, $$item{result}, "$count: $$item{date}");
}

done_testing;
