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
		hashref  =>  [{kind => 'Date', type => 'Gregorian', year => '1950'}],
		order    =>  1,
	},
	'Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{kind => 'Date', type => 'Gregorian', month => 'Jun', year => '1950'}],
		order    =>  2,
	},
	'21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{kind => 'Date', type => 'Gregorian', day => 21, month => 'Jun', year => '1950'}],
		order    =>  3,
	},
	'1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    =>  4,
	},
	'Jun 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{kind => 'Date', type => 'Gregorian', month => 'Jun', year => '1950/00'}],
		order    =>  5,
	},
	'21 Jun 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{kind => 'Date', type => 'Gregorian', day => 21, month => 'Jun', year => '1950/00'}],
		order    =>  6,
	},
	'1950 BCE' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', kind => 'Date', type => 'Gregorian', year => '1950'}],
		order    =>  7,
	},
	'1950/00 BCE' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    =>  8,
	},
	'ABT 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    =>  9,
	},
	'ABT Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'About', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 10,
	},
	'ABT 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'About', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 11,
	},
	'ABT 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 12,
	},
	'ABT 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 13,
	},
	'Aft 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 14,
	},
	'Aft Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'After', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 15,
	},
	'Aft 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'After', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 16,
	},
	'Aft 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 17,
	},
	'Aft 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 18,
	},
	'Bef 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 19,
	},
	'Bef Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Before', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 20,
	},
	'Bef 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'Before', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 21,
	},
	'Bef 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 22,
	},
	'Bef 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 23,
	},
	'Cal 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 24,
	},
	'Cal Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Calculated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 25,
	},
	'Cal 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'Calculated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 26,
	},
	'Cal 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 27,
	},
	'Cal 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 28,
	},
	'Est 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 29,
	},
	'Est Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Estimated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 30,
	},
	'Est 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'Estimated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 31,
	},
	'Est 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 32,
	},
	'Est 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 33,
	},
	'From 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 34,
	},
	'From Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'From', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 35,
	},
	'From 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'From', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 36,
	},
	'From 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 37,
	},
	'From 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 38,
	},
	'To 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 39,
	},
	'To Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'To', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 40,
	},
	'To 21 Jun 1950' =>
	{
		elements =>  1,
		hashref  =>  [{day => 21, flag => 'To', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
		order    => 41,
	},
	'To 1950/00' =>
	{
		elements =>  1,
		hashref  =>  [{flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950/00'}],
		order    => 42,
	},
	'To 1950 bc' =>
	{
		elements =>  1,
		hashref  =>  [{bce => 'BCE', flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950'}],
		order    => 43,
	},
);

my($parser) = Genealogy::Gedcom::Date -> new;

for my $date (sort{$candidates{$a}{order} <=> $candidates{$b}{order} } keys %candidates)
{
	my($result) = $parser -> parse(date => $date);

	is($result, $candidates{$date}{hashref}, "Parsing $date");
}

done_testing;
