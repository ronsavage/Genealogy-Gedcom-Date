#!/usr/bin/env perl

use strict;
use warnings;
use warnings qw(FATAL utf8); # Fatalize encoding glitches.

use Getopt::Long;

use Genealogy::Gedcom::Date;

use Pod::Usage;

# -----------------------------------------------

my($option_parser) = Getopt::Long::Parser -> new();

my(%option);

if ($option_parser -> getoptions
(
	\%option,
	'canonical=i',
	'date=s',
	'help',
	'maxlevel=s',
	'minlevel=s',
) )
{
	pod2usage(1) if ($option{help});

	Genealogy::Gedcom::Date -> new(%option) -> parse;

	# Return 0 for success and 1 for failure.

	exit 0;
}
else
{
	pod2usage(2);
}

__END__

=pod

=head1 NAME

parse.pl - Run Genealogy::Gedcom::Date.

=head1 SYNOPSIS

parse.pl [options]

	Options:
	-canonical $integer
	-date aDate
	-help
	-maxlevel logOption1
	-minlevel logOption2

Exit value: 0 for success, 1 for failure. Die upon error.

=head1 OPTIONS

=over 4

=item o -canonical $integer

Note: You must use one of:

=over 4

=item o canonical => 0

Data::Dumper::Concise's Dumper() prints the output of the parse.

=item o canonical => 1

canonical_form() is called on the output of parse() to print a string.

=item o canonical => 2

canonocal_date() is called on each element in the result from parser), on separate lines.

=back

Default: 0.

=back

Try these:

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015'

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015' -n 0

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015' -n 1

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015' -n 2

=item o -date aDate

A date in Gedcom format. Protect spaces from the shell by using single-quotes.

This option is mandatory.

Default: ''.

=item o -help

Print help and exit.

=item o -maxlevel logOption1

This option affects Log::Handler.

See the Log::handler docs.

Default: 'notice'.

=item o -minlevel logOption2

This option affects Log::Handler.

See the Log::handler docs.

Default: 'error'.

No lower levels are used.

=cut
