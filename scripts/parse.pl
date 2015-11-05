#!/usr/bin/env perl

use strict;
use warnings;
use warnings qw(FATAL utf8); # Fatalize encoding glitches.

use Data::Dumper::Concise;

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
	'normalize=i',
) )
{
	pod2usage(1) if ($option{help});

	# Return 0 for success and 1 for failure.

	my($parser) = Genealogy::Gedcom::Date -> new(%option);
	my($result) = $parser -> parse;

	if ($option{normalize})
	{
		print $parser -> normalize($result). "\n";
	}
	else
	{
		print Dumper($result);
	}

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
	-date aDate
	-help
	-maxlevel logOption1
	-minlevel logOption2
	-normalize $Boolean

Exit value: 0 for success, 1 for failure. Die upon error.

=head1 OPTIONS

=over 4

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

=item o -normalize $Boolean

If set, normalize() is called on the output of parse().

If not, Data::Dumper::Concise's Dumper() is called.

Note: You must use one of:

=over 4

=item o No -n

=item o -n 0

=item o -n 1

=back

I.e.: You cannot use just '-n'. If -n appears, it must be followed by a Boolean.

Default: 0.

=back

Try these:

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015'

	perl -Ilib scripts/parse.pl -d 'From 21 Jun 1950 to @#dGerman@ 05.Dez.2015' -n 1

=cut
