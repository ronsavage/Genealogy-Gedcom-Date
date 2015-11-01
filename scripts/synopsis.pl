#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise;

use Genealogy::Gedcom::Date;

# --------------------------

my($parser) = Genealogy::Gedcom::Date -> new;

print '1: ', Dumper($parser -> parse(calendar => 'Julian', date => '1950') );
print '2: ', Dumper($parser -> parse(calendar => '@#dJulian@', date => '1951') );
print '3: ', Dumper($parser -> parse(date => 'Julian 1952') );
print '4: ', Dumper($parser -> parse(date => '@#dJulian@ 1953') );
print '5: ', Dumper($parser -> parse(date => 'From @#dJulian@ 1954 to Gregorian 1955/56') );
