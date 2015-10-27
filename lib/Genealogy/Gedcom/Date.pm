package Genealogy::Gedcom::Date;

use strict;
use warnings;

use Config;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date::Actions;

use Log::Handler;

use Marpa::R2;

use Moo;

use Try::Tiny;

use Types::Standard qw/Any Bool Int HashRef Str/;

has bnf =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has calendar =>
(
	default  => sub{return 'gregorian'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has date =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has error =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has grammar =>
(
	default  => sub {return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has logger =>
(
	default  => sub{return undef},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has maxlevel =>
(
	default  => sub{return 'notice'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has minlevel =>
(
	default  => sub{return 'error'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has recce =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has result =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

our $VERSION = '2.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

	if (! defined $self -> logger)
	{
		$self -> logger(Log::Handler -> new);
		$self -> logger -> add
		(
			screen =>
			{
				maxlevel       => $self -> maxlevel,
				message_layout => '%m',
				minlevel       => $self -> minlevel,
			}
		);
	}

	# 1 of 2: Initialize the action class via global variables - Yuk!
	# The point is that we don't create an action instance.
	# Marpa creates one but we can't get our hands on it.

	$Genealogy::Gedcom::Date::Actions::logger = $self -> logger;

	$self -> bnf
	(
<<'END_OF_GRAMMAR'

:default				::= action => [values]

lexeme default			=  latm => 1		# Longest Acceptable Token Match.

# Rules, in top-down order (more-or-less).

:start					::= gedcom_date

gedcom_date				::= date
							| lds_ord_date

date					::= calendar_escape calendar_date

calendar_date			::= gregorian_date				action => gregorian_date
							| julian_date				action => julian_date
#							| french_date
#							| german_date
#							| hebrew_date

gregorian_date			::= day gregorian_month gregorian_year
							| gregorian_month gregorian_year
							| gregorian_year_bce
							| gregorian_year

day						::= one_or_two_digits			action => day

gregorian_month			::= gregorian_month_name		action => gregorian_month

gregorian_year			::= number						action => year
							| number ('/') two_digits	action => year

gregorian_year_bce		::= gregorian_year bce			action => gregorian_year_bce

julian_date				::= day gregorian_month_name year
							| gregorian_month_name year
							| julian_year_bce
							| year

julian_year_bce			::= year bce					action => julian_year_bce

#year_bce				::= year bce

year					::= number						action => year

#french_date				::= year_bce
#							| year
#							| french_month_name year
#							| day french_month_name year
#
#german_date				::= german_year
#							| german_month_name dot german_year
#							| day dot german_month_name dot german_year
#							| german_month_name german_year
#
#german_year				::= year
#							| year german_bce
#
#hebrew_date			::= year_bce
#							| year
#							| hebrew_month year
#							| day hebrew_month year

calendar_escape			::=
calendar_escape			::= ('@#d') calendar_name ('@')	action => calendar_escape

lds_ord_date			::= date_value

date_value				::= date_period
							| date_range
							| approximated_date
							| interpreted_date			action => interpreted_date
							| '(' date_phrase ')'		action => date_phrase

date_period				::= from_date
							| to_date
							| from_date to_date

from_date				::= from date					action => from_date

to_date					::= to date			 			action => to_date

date_range				::= before date					action => before_date
							| after date				action => after_date
							| between date and date		action => between_date

approximated_date		::= about date					action => about_date
							| calculated date			action => calculated_date
							| estimated date			action => estimated_date

interpreted_date		::= interpreted date '(' date_phrase ')'

date_phrase				::= date_text

# Lexemes, in alphabetical order.

about					~ 'abt':i
							| 'about':i
							| 'circa':i

after					~ 'aft':i
							| 'after':i

and						~ 'and':i

bce						~ 'bc':i
							| 'b.c':i
							| 'b.c.':i
							| 'bc.':i
							| 'b c':i
							| 'bce':i

before					~ 'bef':i
							| 'before':i

between					~ 'bet':i
							| 'between':i

calculated				~ 'cal':i
							| 'calculated':i

calendar_name			~ 'french r':i
							| 'frenchr':i
							| 'german':i
							| 'gregorian':i
							| 'hebrew':i
							| 'julian':i

date_text				~ [\w ]+

digit					~ [0-9]

#dot					~ '.'

estimated				~ 'est':i
							| 'estimated':i

#french_month_name		~ 'vend' | 'brum' | 'frim' | 'nivo' | 'pluv' | 'vent'
#							| 'germ' | 'flor' | 'prai' | 'mess' | 'ther' | 'fruc' | 'comp'

from					~ 'from':i

#german_bce				~ 'vc'
#							| 'v.c.'
#							| 'v.chr.'
#							| 'vchr'
#							| 'vuz'
#							| 'v.u.z.'
#
#german_month_name		~ 'jan' | 'feb' | 'mär' | 'maer' | 'mrz' | 'apr' | 'mai' | 'jun'
#							| 'jul' | 'aug' | 'sep' | 'sept' | 'okt' | 'nov' | 'dez'

gregorian_month_name		~ 'jan':i | 'feb':i | 'mar':i | 'apr':i | 'may':i | 'jun':i
							| 'jul':i | 'aug':i | 'sep':i | 'oct':i | 'nov':i | 'dec':i

#hebrew_month_name		~ 'tsh' | 'csh' | 'ksl' | 'tvt' | 'shv' | 'adr'
#							| 'ads' | 'nsn' | 'iyr' | 'svn' | 'tmz' | 'aav' | 'ell'

interpreted				~ 'int':i
							| 'interpreted':i

number					~ digit+

one_or_two_digits		~ digit
							| digit digit

to						~ 'to':i

two_digits				~ digit digit

# Boilerplate.

:discard				~ whitespace
whitespace				~ [\s]+

END_OF_GRAMMAR
	);

	$self -> grammar
	(
		Marpa::R2::Scanless::G -> new
		({
			source => \$self -> bnf
		})
	);

} # End of BUILD.

# ------------------------------------------------

sub decode_result
{
	my($self, $result) = @_;
	my(@worklist) = $result;

	my($obj);
	my($ref_type);
	my(@stack);

	do
	{
		$obj      = shift @worklist;
		$ref_type = ref $obj;

		if ($ref_type eq 'ARRAY')
		{
			unshift @worklist, @$obj;
		}
		elsif ($ref_type eq 'HASH')
		{
			push @stack, {%$obj};
		}
		elsif ($ref_type)
		{
			die "Unsupported object type $ref_type\n";
		}
		else
		{
			push @stack, $obj;
		}

	} while (@worklist);

	return [@stack];

} # End of decode_result.

# ------------------------------------------------

sub log
{
	my($self, $level, $s) = @_;

	$self -> logger -> log($level => $s) if ($self -> logger);

} # End of log.

# --------------------------------------------------

sub parse
{
	my($self, %args) = @_;
	my($date)        = $self -> date;
	$date            = defined($args{date}) ? $args{date} : $date;
	$date            =~ tr/,/ /s;

	$self -> date($date);
	$self -> error('');
	$self -> recce
	(
		Marpa::R2::Scanless::R -> new
		({
			grammar           => $self -> grammar,
			semantics_package => 'Genealogy::Gedcom::Date::Actions',
		})
	);

	my($result) = [];

	try
	{
		$self -> recce -> read(\$date);

		my($ambiguity_metric) = $self -> recce -> ambiguity_metric;

		if ($ambiguity_metric <= 0)
		{
			my($message) = "Call to ambiguity_metric() returned $ambiguity_metric";

			$self -> error($message);

			$self -> log(error => "Parse failed. $message");
		}
		elsif ($ambiguity_metric == 1)
		{
			# No ambiguity.

			my($value) = $self -> recce -> value;
			$value     = $self -> decode_result($$value);
			$result    = [$value];

			$self -> log(debug => "Only solution: \n" . Dumper($value) );
		}
		else
		{
			my($count) = 0;

			while (my $value = $self -> recce -> value)
			{
				$value = $self -> decode_result($$value);

#				$self -> log(debug => "Compare $Genealogy::Gedcom::Date::Actions::calendar_escape eq $$value{type}");
				$self -> log(debug => 'value: ' . Dumper($value) );

				#if ($Genealogy::Gedcom::Date::Actions::calendar_escape eq $$value{type})
				{
					push @$result, $value;

					$self -> log(debug => "Solution @{[++$count]}: \n" . Dumper($_) ) for @$value;
				}
			}
		}
	}
	catch
	{
		$self -> error($_);
	};

	return $result;

} # End of parse.

# --------------------------------------------------

1;

=pod

=encoding utf8

=head1 NAME

Genealogy::Gedcom::Date - Parse GEDCOM dates

=head1 Synopsis

	#!/usr/bin/env perl

	use strict;
	use warnings;

	use Data::Dumper::Concise; # For Dumper().

	use Genealogy::Gedcom::Date;

	my($parser) = Genealogy::Gedcom::Date -> new;

	for my $candidate
	(
		'ABT 10 JUL 2003',
		'CAL 10 JUL 2003',
		'EST 1700',
		'FROM 1522 TO 1534',
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

See the L</FAQ>'s first QA for the definition of $result.

This code is a fragment of scripts/synopsis.pl.

=head1 Description

L<Genealogy::Gedcom::Date> provides a parser for GEDCOM dates.

See L<the GEDCOM Specification|http://wiki.webtrees.net/en/Main_Page>.

=head1 Installation

Install L<Genealogy::Gedcom::Date> as you would for any C<Perl> module:

Run:

	cpanm Genealogy::Gedcom::Date

or run:

	sudo cpan Genealogy::Gedcom::Date

or unpack the distro, and then either:

	perl Build.PL
	./Build
	./Build test
	sudo ./Build install

or:

	perl Makefile.PL
	make (or dmake or nmake)
	make test
	make install

=head1 Constructor and Initialization

C<new()> is called as C<< my($parser) = Genealogy::Gedcom::Date -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<Genealogy::Gedcom::Date>.

Key-value pairs accepted in the parameter list (see corresponding methods for details
[e.g. date()]):

=over 4

=item o calendar => $name

The name of the calendar to use as the default.

See L</calendar([$name])> for details.

Default: 'Gregorian'.

=item o date => $date

The string to be parsed.

This string is always converted to lower case before being processed. Further, ',' and '.' are
replaced by spaces. See the L</FAQ> for details.

See L</date([$date])> for details.

Default: ''.

=back

Note: These parameters can also be provided in the call to L</parse([%args])>.

=head1 Methods

=head2 calendar([$name])

Here, [ and ] indicate an optional parameter.

Gets or sets the name of the default calendar.

The name in C<< parse(calendar => $name) >> takes precedence over C<< new(calendar => $name) >>
and C<calendar($name)>.

This means if you call C<parse()> as C<< parse(calendar => $name) >>, then the value C<$name> is
stored so that if you subsequently call C<calendar()>, that value is returned.

See L</What extensions to the Gedcom grammar are supported?> for details.

See also L</What is the meaning of the 'calendar' key in method calls?>.

Note: C<calendar> is a parameter to new().

=head2 date([$date])

Here, [ and ] indicate an optional parameter.

Gets or sets the date to be parsed, or the date which was just parsed.

The date in C<< parse(date => $date) >> takes precedence over C<< new(date => $date) >>
and C<date($date)>.

This means if you call C<parse()> as C<< parse(date => $date) >>, then the value C<$date> is stored
so that if you subsequently call C<date()>, that value is returned.

Note: C<date> is a parameter to new().

=head2 error()

Gets the last error message.

Returns '' (the empty string) if there have been no errors.

If L<Marpa::R2> throws an exception, it is caught by a try/catch block, and the C<Marpa> error
is returned by this method.

=head2 new([%args])

The constructor. See L</Constructor and Initialization>.

=head2 parse([%args])

Here, [ and ] indicate an optional parameter.

C<parser()> returns 0 for success and 1 for failure.

C<parse()> is often the only method you'll need to call, after calling C<new()>.

Upon success, call L</result()> to retrieve the hashref discussed in the first FAQ.

Upon failure, call L</error()> to retrieve the error message.

C<parse()> takes the same parameters as C<new()>.

=head1 FAQ

=head2 What is the format of the hashref returned by result()?

It has these key => value pairs:

=over 4

=item o one => $first_date_in_range

Returns the first (or only) date as a string, after 'Abt', 'Bef', 'From' or whatever.

This is for cases like '1999' in 'abt 1999', '1999' in 'bef 1999, '1999' in 'from 1999', and for
'1999' in 'from 1999 to 2000'.

A missing month defaults to 01. A missing day defaults to 01.

'500BC' will be returned as '0500-01-01', with the 'one_bc' flag set. See also the key 'one_date'.

Default: DateTime::Infinite::Past -> new, which stringifies to '-inf'.

Note: On some systems (MS Windows), DateTime::Infinite::Past -> new stringifies to '-1.#INF', but,
as of V 1.09, the code changes this to '-Inf'.
Likewise, on some systems (Solaris), DateTime::Infinite::Past -> new stringifies to '-Infinity',
but, as of V 1.09, the code changes this to '-Inf'.

The default value does I<not> set the one_ambiguous and one_bc flags.

=item o one_ambiguous => $Boolean

Returns 1 if the first (or only) date is ambiguous. Possibilities:

=over 4

=item o Only the year is present

=item o Only the year and month are present

=item o The day and month are reversible

This is checked for by testing whether or not the day is <= 12, since in that case it could be a
month.

=back

Obviously, the 'one_ambiguous' flag can be set for a date specified in a non-ambiguous way, e.g.
'From 1 Jan 2000',
since the numeric value of the month is 1 and the day is also 1.

Default: 0.

=item o one_bc => $Boolean

Returns 1 if the first date is followed by one of (case-insensitive): 'B.C.', 'BC.' or 'BC'. 'BC'
may be written as 'BCE', with or without full-stops.

In the input, this suffix can be separated from the year by spaces, so both '500BC' and '500 B.C.'
are accepted.

Default: 0.

=item o one_date => $a_date_object

This object is of type L<DateTime>.

Warning: Since these objects only accept 4-digit years, any year 0 .. 999 will have 1000 added to
it.
Of course, the value for the 'one' key will I<not> have 1000 added it.

This means that if the value of the 'one' key does not match the stringified value of the 'one_date'
key (assuming the latter is not '-Inf'), then the year is < 1000.

Alternately, if the stringified value of the 'one_date' key is '-Inf', the period supplied did not
have a 'From' date.

Default: DateTime::Infinite::Past -> new, which stringifies to '-Inf'.

Note: On some systems (MS Windows), DateTime::Infinite::Past -> new stringifies to '-1.#INF', but,
as of V 1.09, the code changes this to '-Inf'. Likewise, on some systems (Solaris),
DateTime::Infinite::Past -> new stringifies to '-Infinity', but, as of V 1.09, the code changes
this to '-Inf'.

=item o one_default_day => $Boolean

Returns 1 if the input date had no value for the first date's day. The code sets the default day to
1.

Default: 0.

=item o one_default_month => $Boolean

Returns 1 if the input date had no value for the first date's month. The code sets the default month
to 1.

Default: 0.

=item o phrase => $string

This holds the text, if any, between '(' and ')' in an interpreted date.

Default: ''.

=item o prefix => $string

Possible values for the prefix:

=over 4

=item o 'abt', given the approximate date 'Abt 1999'

=item o 'aft', given the date range 'Aft 1999'

=item o 'bef', given the date range 'Bef 1999'

=item o 'bet', given the date range 'Bet 1999 and 2000'

=item o 'cal', given the approximate date 'Cal 1999'

=item o 'est', given the approximate date 'Est 1999'

=item o 'from', given the date period 'From 1999' or 'From 1999 to 2000'

=item o 'int', given the interpreted date 'Int 1999 (Guesswork)'

=item o 'phrase', given the date phrase '(Unknown)'

=item o 'to', given the date period 'To 2000'

=back

Default: ''.

=item o two => $second_date_in_range

Returns the second (or only) date as a string, after 'and' in 'bet 1999 and 2000', or 'to' in 'from
1999 to 2000', or '2000' in 'to 2000'.

A missing month defaults to 01. A missing day defaults to 01.

'500BC' will be returned as '0500-01-01', with the 'two_bc' flag set. See also the key 'two_date'.

Default: DateTime::Infinite::Future -> new, which stringifies to 'inf'.

Note: On some systems (MS Windows), DateTime::Infinite::Future -> new stringifies to '1.#INF', but,
as of V 1.03, the code changes this to 'Inf'. Likewise, on some systems (Solaris),
DateTime::Infinite::Future -> new stringifies to 'Infinity', but, as of V 1.07, the code changes
this to 'Inf'.

The default value does I<not> set the two_ambiguous and two_bc flags.

=item o two_ambiguous => $Boolean

Returns 1 if the second (or only) date is ambiguous. Possibilities:

=over 4

=item o Only the year is present

=item o Only the year and month are present

=item o The day and month are reversible

This is checked for by testing whether or not the day is <= 12, since in that case it could be a
month.

=back

Obviously, the 'two_ambiguous' flag can be set for a date specified in a non-ambiguous way, e.g.
'To 1 Jan 2000', since the numeric value of the month is 1 and the day is also 1.

Default: 0.

=item o two_bc => $Boolean

Returns 1 if the second date is followed by one of (case-insensitive): 'B.C.', 'BC.' or 'BC'. 'BC'
may be written as 'BCE', with or without full-stops.

In the input, this suffix can be separated from the year by spaces, so both '500BC' and '500 B.C.'
are accepted.

Default: 0.

=item o two_date => $a_date_object

This object is of type L<DateTime>.

Warning: Since these objects only accept 4-digit years, any year 0 .. 999 will have 1000 added to
it. Of course, the value for the 'two' key will I<not> have 1000 added it.

This means that if the value of the 'two' key does not match the stringified value of the
'two_date' key (assuming the latter is not 'Inf'), then the year is < 1000.

Alternately, if the stringified value of the 'two_date' key is 'Inf', the period supplied did not
have a 'To' date.

Default: DateTime::Infinite::Future -> new, which stringifies to 'inf'.

Note: On some systems (MS Windows), DateTime::Infinite::Future -> new stringifies to '1.#INF', but,
as of V 1.09, the code changes this to 'Inf'. Likewise, on some systems (Solaris),
DateTime::Infinite::Future -> new stringifies to 'Infinity', but, as of V 1.09, the code changes
this to 'Inf'.

=item o two_default_day => $Boolean

Returns 1 if the input date had no value for the second date's day. The code sets the default day
to 1.

Default: 0.

=item o two_default_month => $Boolean

Returns 1 if the input date had no value for the second date's month. The code sets the default
month to 1.

Default: 0.

=back

=head2 What is the meaning of the 'calendar' key in method calls?

Possible values (case-insensitive):

=over 4

=item o calendar => 'French'

Expect dates in 'month day year' format, as in From Jan 2 2011 BC to Mar 4 2011.

=item o calendar => 'German'

=item o calendar => 'Gregorian'

Expect dates in 'day month year' format, as in From 1 Jan 2001 to 25 Dec 2002.

This is the default.

=item o calendar => 'Hebrew'

Expect dates in 'year month day' format, as in 2011-01-02 to 2011-03-04.

=item o calendar => 'Julian'

Expect dates in 'year month day' format, as in 2011-01-02 to 2011-03-04.

=back

=head2 Does this module accept Unicode characters?

Yes. Seel scripts/synopsis.pl.

=head2 Are dates massaged before being processed?

Yes. They are lower-cased, and commas are replaced with spaces. So that's how they are returned if
you call L</date($date)> to retrieve the date actually processed.

=head2 What extensions to the Gedcom grammar are supported?

Note: Please read the preceeding QA first!

Calendar names:

Use 'dfrench r', 'dfrenchr', 'dgerman', 'dgregorian', 'dhebrew' or 'djulian'.

Date types:

=over 4

=item o 'about' may be spelled as 'abt', 'about' or 'circa'

=item o 'after' may be spelled as 'aft' or 'after'

=item o 'before' may be spelled as 'bef' or 'before'

=item o 'between' may be spelled as 'bet' or 'between'

=item o 'calculated' may be spelled as 'cal' or 'calculated'

=item o 'estimated' may be spelled as 'est' or 'estimated'

=item o 'interpreted' may be spelled as 'int' or 'interpreted'

=back

Month names:

=over 4

=item o French months

Use 'vend' | 'brum' | 'frim' | 'nivo' | 'pluv' | 'vent' | 'germ' | 'flor' | 'prai' | 'mess' | 'ther'
| 'fruc' | 'comp'.

=item o German months

Use 'jan' | 'feb' | 'mär' | 'maer' | 'mrz' | 'apr' | 'mai' | 'jun' | 'jul' | 'aug' | 'sep' | 'sept'
| 'okt' | 'nov' | 'dez'.


=back

BC:

=over 4

=item o Gregorian BC may be spelled as 'bc', 'b c' or 'bce'

=item o German BC may be spelled as 'vc', 'v c', 'v chr', 'vchr', 'vuz' or 'v u z'

=back

=head2 Do you accept suggestion regarding other extensions?

Yes, but they must not be ambiguous.

=head2 Are Gregorian dates of the form 1699/00 handled?

Yes. Specifically, '1 Dec 1699/00' is returned as '1 dec 1699 00'.

See scripts/synopsis.pl.

=head2 Your module rejected my date!

There are many possible reasons for this. One is:

=over 4

=item o The date is in American format (month before year), but the code was not warned

See L</calendar([$name])> for a list of supported calendars.

=back

=head2 Does this module respect the ENV{LANG} variable?

Yes. When DateTime objects are created, the C<locale> parameter is set to $ENV{LANG} if the latter
is set.

=head2 On what systems do DateTime::Inifinite::(Past, Future) return '-1.#INF' and '1.#INF'?

So far (as reported by CPAN Testers):

=over 4

=item o Win32::GetOSName = Win7

=item o Win32::GetOSName = WinXP/.Net

=back

=head2 On what systems do DateTime::Inifinite::(Past, Future) return '-Infinity' and 'Infinity'?

So far (as reported by CPAN Testers):

=over 4

=item o osname=solaris, osvers=2.11

=back

=head2 How do I format dates for output?

Use the hashref keys 'one' and 'two', to get dates in the form 2011-06-21. Re-format as necessary.

Such a hashref is returned from the L</result()> method.

=head2 Does this module handle non-Gregorian calendars?

Yes. See L</calendar([$name])> for more details.

=head2 How are incomplete dates handled?

A missing month is set to 1 and a missing day is set to 1.

Further, in the hashref returned by the L</result()>, the flags one_default_month,
one_default_day, two_default_month and two_default_day are set to 1, as appropriate, so you can
tell that the code supplied the value.

Note: These flags take a Boolean value; it is only by coincidence that they can take the value of
the default month or day.

=head2 Why are dates returned as objects of type L<DateTime>?

Because such objects have the sophistication required to handle such a complex topic.

See L<DateTime> and L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

=head2 What happens if C<parse()> is given a string like 'From 2000 to 1999'?

Then the returned hashref will have:

=over 4

=item o one => '2000-01-01T00:00:00'

=item o two => '1999-01-01T00:00:00'

=back

Clearly then, the code I<does not> reorder the dates.

=head2 Why was this module renamed from DateTime::Format::Gedcom?

The L<DateTime> suite of modules aren't designed, IMHO, for GEDCOM-like applications. It was a
mistake to use that name in the first place.

By releasing under the Genealogy::Gedcom::* namespace, I can be much more targeted in the data
types I choose as method return values.

=head2 Why did you choose Moo over Moose?

My policy is to use the lightweight L<Moo> for all modules and applications.

=head1 TODO

=over 4

=item o Comparisons between dates

Sample code to overload '<' and '>' as in L<Gedcom::Date>.

=back

=head1 See Also

=head2 Modules

L<DateTime>.

L<DateTime::Moonpig>.

L<DateTimeX::Lite>.

L<Genealogy::Gedcom>.

L<Time::Duration>, which is more sophisticated than L<Time::Elapsed>.

L<Time::Moment> implements L<ISO 8601|https://en.wikipedia.org/wiki/ISO_8601>.

L<Time::ParseDate>.

L<Time::Piece>, which is in Perl core.

=head2 Articles

L<http://perltricks.com/article/59/2014/1/10/Solve-almost-any-datetime-need-with-Time-Piece>.

The next two articles discuss a wide range of modules:

L<http://blogs.perl.org/users/buddy_burden/2015/09/a-date-with-cpan-part-1-state-of-the-union.html>.

L<http://blogs.perl.org/users/buddy_burden/2015/10/a-date-with-cpan-part-2-target-first-aim-afterwards.html>.

=head1 Machine-Readable Change Log

The file Changes was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Repository

L<https://github.com/ronsavage/Genealogy-Gedcom-Date>.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy::Gedcom::Date>.

=head1 Credits

Thanx to Eugene van der Pijll, the author of the Gedcom::Date::* modules.

Thanx also to the authors of the DateTime::* family of modules. See
L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

Thanx for Mike Elston on the perl-gedcom mailing list for providing French month abbreviations,
amongst other information pertaining to the French language.

Thanx to Michael Ionescu on the perl-gedcom mailing list for providing the grammar for German dates
and German month abbreviations.

=head1 Author

L<Genealogy::Gedcom::Date> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Homepage: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
