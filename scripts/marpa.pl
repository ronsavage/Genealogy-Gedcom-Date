#!/usr/bin/env perl

use strict;
use warnings;

use Genealogy::Gedcom::Date;

# --------------------------

my($candidate) = shift;
my($parser)    = Genealogy::Gedcom::Date -> new;

my($result);

for my $date
(
	'15 Jul 1954',
	'10 JUL 2003',
	'JUL 2003',
	'2003',
	'ABT 10 JUL 2003',
	'CAL 10 JUL 2003',
	'EST 10 JUL 2003',
	'FROM 10 JUL 2003',
	'TO 10 JUL 2003',
	'FROM 10 JUL 2003 TO 20 JUL 2003',
	'AFT 10 JUL 2003',
	'BEF 10 JUL 2003',
	'BET 10 JUL 2003 AND 20 JUL 2003',
	'Aft 1 Jan 2001',
	'From 0',
	'Abt 1 Jan 2001',
	'Abt 4000 BC',
	'Cal 2345 BC',
	'Cal 31 Dec 2000',
	'Est 1 Jan 2001',
	'Est 1234BC',
	'From 2011 BC to 4 Mar 2011',
	'From 2 Jan 2011 to 4 Mar 2011',
)
{
	$result = $parser -> parse(date => $date);

	if ($result)
	{
		print "Date: $result. \n";
	}
	else
	{
		print "Error: Can't parse '$date'. \n";
	}
}

for my $date
(
	'INT 10 JUL 2003 (foo)', 			# Contains junk.
	'(foo)',							# Is junk.
	'From Jan 2 2011 to 4 Mar 2011',	# Is American.
)
{
	$result = $parser -> parse(date => $date);

	if ($result)
	{
		print "Date: $result. \n";
	}
	else
	{
		print "Error: Can't parse '$date'. \n";
	}
}
