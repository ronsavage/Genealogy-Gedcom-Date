#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date;

# --------------------------

my($parser) = Genealogy::Gedcom::Date -> new;

print "Expected successes: \n";

my($result);

for my $date
(
	'15 Jul 1954',
	'10 JUL 2003',
	'JUL 2003',
	'2003',
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
	'1 Jan 1000',
	'1 Jan 900',
	'1950 B C',
	'1950 BC',
	'1950 B.C',
	'1950 BC.',
	'1950 B.C.',
	'1950 BCE',
	'21.mär.1999',
)
{
	print "Date: $date. ";

	$result = $parser -> parse(date => $date);

	if ($#$result < 0)
	{
		print $parser -> error();
	}
	else
	{
		print Dumper($_) for @$result;
	}
}

print "Expected failures: \n";

for my $date
(
	'From Jan 2 2011 to 4 Mar 2011',	# Format is American.
)
{
	print "Date: $date. ";

	# Return 0 for success and 1 for failure.

	$result = $parser -> parse(date => $date);

	if ($#$result < 0)
	{
		print $parser -> error();
	}
	else
	{
		print Dumper($_) for @$result;
	}
}
