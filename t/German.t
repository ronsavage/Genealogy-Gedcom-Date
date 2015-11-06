#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date;

use Test::Stream -V1;

# ------------------------------------------------

my(@candidates) =
(
	{	# 1
		date   => 'German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', kind => 'Date', type => 'German', month => 'Feb', year => '1950'}],
	},
	{
		date   => 'German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', kind => 'Date', type => 'German', month => 'Feb', year => '1950'}],
	},
	{
		date   => '21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', kind => 'Date', type => 'German', day => 21, month => 'Feb', year => '1950'}],
	},
	{
		date   => 'German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', kind => 'Date', type => 'German', day => 21, month => 'Feb', year => '1950'}],
	},
	{
		date   => 'Abt German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'ABT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'ABT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'ABT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{	# 10
		date   => 'Abt German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'ABT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Abt German 1950 VCHR',
		result => [{canonical => '@#dGERMAN@ 1950 VCHR', bce => 'VCHR', flag => 'ABT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'AFT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'AFT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'AFT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'AFT', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Aft German 1950 v.u.z.',
		result => [{canonical => '@#dGERMAN@ 1950 v.u.z.', bce => 'v.u.z.', flag => 'AFT', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'BEF', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{	# 20
		date   => 'Bef German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'BEF', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'BEF', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'BEF', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Bef German 1950 v.c.',
		result => [{canonical => '@#dGERMAN@ 1950 v.c.', bce => 'v.c.', flag => 'BEF', kind => 'Date', type => 'German', year => '1950'}],
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
			{canonical => '1501/01', flag => 'BET', kind => 'Date', suffix => '01', type => 'Gregorian', year => '1501'},
			{canonical => '@#dGERMAN@ 1510', flag => 'AND', kind => 'Date', type => 'German', year => '1510'},
		],
	},
	{	# 30
		date   => 'Bet German 1501 and 1510/02',
		result =>
		[
			{canonical => '@#dGERMAN@ 1501', flag => 'BET', kind => 'Date', type => 'German', year => '1501'},
			{canonical => '1510/02', flag => 'AND', kind => 'Date', suffix => '02', type => 'Gregorian', year => '1510'},
		],
	},
	{
		date   => 'Cal German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'CAL', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'CAL', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'CAL', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'CAL', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Cal German 1950 v.chr.',
		result => [{canonical => '@#dGERMAN@ 1950 v.chr.', bce => 'v.chr.', flag => 'CAL', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{	# 40
		date   => 'Est 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
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
		date   => 'Est Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'EST', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'Est German 1950 vc',
		result => [{canonical => '@#dGERMAN@ 1950 vc', bce => 'vc', flag => 'EST', kind => 'Date', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{	# 50
		date   => 'From Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'FROM', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German Feb.1950',
		result => [{canonical => '@#dGERMAN@ Feb.1950', flag => 'FROM', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'From 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'FROM', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 21.Feb.1950',
		result => [{canonical => '@#dGERMAN@ 21.Feb.1950', day => 21, flag => 'FROM', kind => 'Date', month => 'Feb', type => 'German', year => '1950'}],
	},
	{
		date   => 'From German 1950 v.chr.',
		result => [{canonical => '@#dGERMAN@ 1950 v.chr.', bce => 'v.chr.', flag => 'FROM', kind => 'Date', type => 'German', year => '1950'}],
	},
	{	# 55
		date   => 'To German 1950',
		result => [{canonical => '@#dGERMAN@ 1950', flag => 'TO', kind => 'Date', type => 'German', year => '1950'}],
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

	#print STDERR "Expect: \n", Dumper($$item{result});
	#print STDERR "Got: \n", Dumper($result);

	is($result, $$item{result}, "$count: $$item{date}");
}

done_testing;
