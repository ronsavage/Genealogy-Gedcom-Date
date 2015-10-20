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
	'date=s',
	'help',
	'maxlevel=s',
	'minlevel=s',
) )
{
	pod2usage(1) if ($option{'help'});

	# Return 0 for success and 1 for failure.

	exit Genealogy::Gedcom::Date -> new(%option) -> parse;
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
	-date aDate
	-help
	-maxlevel logOption1
	-minlevel logOption2

Exit value: 0 for success, 1 for failure. Die upon error.

=head1 OPTIONS

=over 4

=item -date aDate

A date in Gedcom format. Protect spaces from the shell by using single-quotes.

This option is mandatory.

Default: ''.

=item -help

Print help and exit.

=item -maxlevel logOption1

This option affects Log::Handler.

See the Log::handler docs.

Default: 'notice'.

=item -minlevel logOption2

This option affects Log::Handler.

See the Log::handler docs.

Default: 'error'.

No lower levels are used.

=back

=cut
