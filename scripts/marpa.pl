#!/usr/bin/env perl

use strict;
use warnings;

use Genealogy::Gedcom::Date;

# --------------------------

my($candidate) = shift;
my($result)    = Genealogy::Gedcom::Date -> new
(
	maxlevel => 'debug',
) -> run($candidate);
