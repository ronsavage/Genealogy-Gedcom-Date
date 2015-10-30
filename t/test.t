#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date;

use Test::Stream -V1;

# -------------------------

=pod

	'ABT 10 JUL 2003',
	'CAL 1922',
	'CAL 10 JUL 2003',
	'EST 1700',
	'EST 10 JUL 2003',
	'FROM 1522 TO 1534',
	'FROM 30 APR 1980',
	'FROM 10 JUL 2003',
	'TO 1910',
	'TO 10 JUL 2003',
	'FROM 10 JUL 2003 TO 20 JUL 2003',
	'AFTER 1948',
	'AFT 10 JUL 2003',
	'BEF 2 AUG 2003',
	'BEF 10 JUL 2003',
	'BET 1600 AND 1620',
	'BET 1 JAN 1852 AND 31 DEC 1852',
	'BET 1 JAN 1852 AND DEC 1852',
	'BET JAN 1852 AND 31 DEC 1852',
	'BET JAN 1852 AND DEC 1852',
	'BET 1 JAN 1920 AND 31 JAN 1920',
	'BET 10 JUL 2003 AND 20 JUL 2003',
	'Aft 1 Jan 2001',
	'From 0',
	'Abt 1 Jan 2001',
	'Abt 4000 BC',
	'Cal 2345 BC',
	'Cal 31 Dec 2000',
	'Est 1 Jan 2001',
	'Est 1234BC',
	'FROM 1904 to 1915',
	'FROM 1904',
	'TO 1915',
	'From 2011 BC to 4 Mar 2011',
	'From 2 Jan 2011 to 4 Mar 2011',
	'16 Jan, 2011',
	'1 Dec 1699/00',
	'INT 12 APR 1657 (Easter Monday)',
	'INT 10 JUL 2003 (foo)',
	'(Once upon a time)',
	'(foo)',

	'From Jan 2 2011 to 4 Mar 2011',	# Is American.

=cut

my(%candidates) =
(
	'1950' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian', year => '1950'},
		order    =>  1,
	},
	'Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian', month => 'Jun', year => '1950'},
		order    =>  2,
	},
	'21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian', day => 21, month => 'Jun', year => '1950'},
		order    =>  3,
	},
	'1950/00' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian',year => '1950/00'},
		order    =>  4,
	},
	'Jun 1950/00' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian', month => 'Jun', year => '1950/00'},
		order    =>  5,
	},
	'21 Jun 1950/00' =>
	{
		elements =>  1,
		hashref  =>  {kind => 'date', type => 'gregorian', day => 21, month => 'Jun', year => '1950/00'},
		order    =>  6,
	},
);

my($parser) = Genealogy::Gedcom::Date -> new;

for my $date (sort{$candidates{$a}{order} <=> $candidates{$b}{order} } keys %candidates)
{
	my($result) = $parser -> parse(date => $date);

	if ($candidates{$date}{elements} == 1)
	{
		$result = $$result[0];
	}

	note "Date: $date: \n", Dumper($result);

	is($result, $candidates{$date}{hashref});
}

done_testing;
