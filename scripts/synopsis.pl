#!/usr/bin/env perl

use strict;
use warnings;

use Genealogy::Gedcom::Date;

# --------------------------

sub process
{
	my($count, $parser, $date) = @_;

	print "$count: ";

	my($result) = $parser -> parse(date => $date);

	print 'Canonical date: ', $parser -> canonical_date($$result[$_]), ". \n" for (0 .. $#$result);
	print 'Canonical form: ', $parser -> canonical_form($result), ". \n";
	print "\n";

} # End of process.

# --------------------------

my($parser) = Genealogy::Gedcom::Date -> new(maxlevel => 'debug');
my($date)   =

process(1, $parser, 'Julian 1950');
process(2, $parser, '@#dJulian@ 1951');
process(3, $parser, 'From @#dJulian@ 1952 to Gregorian 1953/54');
process(4, $parser, 'From @#dFrench r@ 1955 to 1956');
process(5, $parser, 'From @#dJulian@ 1957 to German 1.Dez.1958');
