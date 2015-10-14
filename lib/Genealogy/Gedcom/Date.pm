package Genealogy::Gedcom::Date;

use strict;
use warnings;

use Config;

use DateTime;
use DateTime::Infinite;

use Marpa::R2;

use Moo;

use Try::Tiny;

use Types::Standard qw/Any Bool Int Str/;

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

has recce =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

our $VERSION = '2.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

	# Policy: Event names are always the same as the name of the corresponding lexeme.

	$self -> bnf
	(
<<'END_OF_GRAMMAR'

:default					::= action => [values]

lexeme default				=  latm => 1		# Longest Acceptable Token Match.

# Rules, (more-or-less) in top-down order.

:start						::= gedcom_date

gedcom_date					::= date
								| date_lds_ord

date						::= date_calendar_name
								| date_calendar_escape

date_calendar_name			::= date_french
								| date_gregorian
								| date_hebrew
								| date_julian

date_french					::= year_bc
								| year
								| french_month year
								| day french_month year

year_bc						::= year bc

year						::= number

date_gregorian				::= year_gregorian_bc
								| year_gregorian
								| gregorian_month year_gregorian
								| day gregorian_month year_gregorian

date_calendar_escape		::=
date_calendar_escape		::= ('@#') date_calendar_name ('@')

year_gregorian_bc			::= year_gregorian bc

year_gregorian				::= number
								| number ('/') pair_of_digits

date_hebrew					::= year_bc
								| year
								| hebrew_month year
								| day hebrew_month year

date_julian					::= year_bc
								| year
								| gregorian_month year
								| day gregorian_month year

date_lds_ord				::= date_value

date_value					::= date
								| date_period
								| date_range
								| date_approximated

date_period					::= from date
								| to date
								| from date to date

date_range					::= before date
								| after date
								| between date and date

date_approximated			::= about date
								| calculated date
								| estimated date

# Lexemes, in alphabetical order.

about						~ 'abt'

after						~ 'aft'

and							~ 'and'

bc							~ 'bc'
								| 'b.c.'

before						~ 'bef'

between						~ 'bet'

calculated					~ 'cal'

day							~ digit
								| digit digit

digit						~ [0-9]

estimated					~ 'est'

french_month				~ 'vend' | 'brum' | 'frim' | 'nivo' | 'pluv' | 'vent'
								| 'germ' | 'flor' | 'prai' | 'mess' | 'ther' | 'fruc' | 'comp'

hebrew_month				~ 'tsh' | 'csh' | 'ksl' | 'tvt' | 'shv' | 'adr'
								| 'ads' | 'nsn' | 'iyr' | 'svn' | 'tmz' | 'aav' | 'ell'

from						~ 'from'

gregorian_month				~ 'jan' | 'feb' | 'mar' | 'apr' | 'may' | 'jun'
								| 'jul' | 'aug' | 'sep' | 'oct' | 'nov' | 'dec'

number						~ digit+

pair_of_digits				~ digit digit

to							~ 'to'

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

sub _decode_result
{
	my($self, $result) = @_;
	my(@worklist)      = $result;

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

	return join(' ', @stack);

} # End of _decode_result.

# --------------------------------------------------

sub _init_flags
{
	my($self) = @_;

	my(%flags);

	for my $key (qw/one two/)
	{
		$flags{$key}                   = $key eq 'one' ? DateTime::Infinite::Past -> new : DateTime::Infinite::Future -> new;
		$flags{"${key}_ambiguous"}     = 0;
		$flags{"${key}_bc"}            = 0;
		$flags{"${key}_date"}          = $flags{$key};
		$flags{"${key}_default_day"}   = 0;
		$flags{"${key}_default_month"} = 0;
		$flags{phrase}                 = '';
		$flags{prefix}                 = '';
	}

	# Fix systems where DateTime::Infinite::Past is returned as '-1.#INF' etc instead of '-Inf'.
	# Likewise a fix for DateTime::Infinite::Future allegedly being '1.#INF' etc instead of 'Inf'.
	# This applies to OSes reported by CPAN Testers as:
	# o Win32::GetOSName = Win7.       $date =~ /-?1\.#INF/.
	# o Win32::GetOSName = WinXP/.Net. $date =~ /-?1\.#INF/.
	# o osname=solaris, osvers=2.11.   $date =~ /-?Infinity/.

	my($minus_infinity) = $Config{version} ge '5.21.11' ? '-Inf' : '-inf';
	my($plus_infinity)  = $Config{version} ge '5.21.11' ? 'Inf'  : 'inf';

	$flags{one} = $flags{one_date} = $minus_infinity if ( ($flags{one} eq '-1.#INF') || ($flags{one} eq '-Infinity') );
	$flags{two} = $flags{two_date} = $plus_infinity  if ( ($flags{two} eq '1.#INF')  || ($flags{two} eq 'Infinity') );

	return {%flags};

} # End of _init_flags.

# --------------------------------------------------

sub parse
{
	my($self, %args)  = @_;
	my($date)         = $self -> date;
	$date             = lc(defined($args{date}) ? $args{date} : $date);
	my($length_input) = length($date);

	$self -> error('');
	$self -> recce
	(
		Marpa::R2::Scanless::R -> new
		({
			grammar => $self -> grammar,
		})
	);

	my($length_processed);
	my($value);

	try
	{
		$length_processed = $self -> recce -> read(\$date);

		if ($length_processed == $length_input)
		{
			$value = $self-> _decode_result(${$self -> recce -> value});
		}
		else
		{
			$self -> error("Input length: $length_input. Length processed: $length_processed");
		}
	}
	catch
	{
		$self -> error($_);
	};

	return $value;

} # End of parse.

# --------------------------------------------------

1;

=pod

=head1 NAME

Genealogy::Gedcom::Date - Parse GEDCOM dates

=head1 Synopsis

	my($parser) = Genealogy::Gedcom::Date -> new;

	# These samples are from t/value.t.

	for my $candidate (
	'Abt 1 Jan 2001', # use parse_approximate_date().
	'Aft 1 Jan 2001', # Use parse_date_range().
	'From 0'          # Use parse_date_period().
	)
	{
		my($hashref) = $parser -> parse(date => $candidate);
	}

See the L</FAQ>'s first QA for the definition of $hashref.

L<Genealogy::Gedcom::Date> ships with t/date.t, t/escape.t and t/value.t. You are strongly
encouraged to peruse them.

=head1 Description

L<Genealogy::Gedcom::Date> provides a parser for GEDCOM dates.

See L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

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

=item o date => $a_string

The string to be parsed.

This string is always converted to lower case before being processed.

Default: ''.

This parameter is optional. It can be supplied to new() or to L<parse_approximate_date([%arg])>,
L<parse_date_period([%arg])> or L<parse_date_range([%arg])>.

=back

=head1 Methods

=head2 date([$string])

=head2 parse([%args])

=head1 FAQ

=head2 Does this module respect the ENV{LANG} variable?

Yes. When DateTime objects are created, the C<locale> parameter is set to $ENV{LANG} if the latter
is set.

=head2 What is the format of the hashref returned by parse_*()?

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

=head2 What is the meaning of the 'calendar' key in calls to the new() and parse() methods?

Possible values (in any case):

=over 4

=item o calendar => 'french'

Expect dates in 'month day year' format, as in From Jan 2 2011 BC to Mar 4 2011.

=item o calendar => 'gregorian'

Expect dates in 'day month year' format, as in From 1 Jan 2001 to 25 Dec 2002.

This is the default.

=item o calendar => 'hebrew'

Expect dates in 'year month day' format, as in 2011-01-02 to 2011-03-04.

=item o calendar => 'julian'

Expect dates in 'year month day' format, as in 2011-01-02 to 2011-03-04.

=back

The string in parse(calendar => $a_string) takes precedence over new(calendar => $a_string).

=head2 How do I format dates for output?

Use the hashref keys 'one' and 'two', to get dates in the form 2011-06-21. Re-format as necessary.

Such a hashref is returned from all parse_*() methods.

=head2 Does this module handle non-Gregorian calendars?

No, not yet. See L</process_date_escape(@field)> for more details.

=head2 How are the various date formats handled?

Firstly, all commas are deleted from incoming dates.

Then, dates are split on ' ', '-' and '/', and the resultant fields are analyzed one at a time.

The 'calendar' key can be used to force the code to assume a certain type of date format. This
option is explained above, in this FAQ.

=head2 How are incomplete dates handled?

A missing month is set to 1 and a missing day is set to 1.

Further, in the hashref returned by the parse_*() methods, the flags one_default_month,
one_default_day, two_default_month and two_default_day are set to 1, as appropriate, so you can
tell that the code supplied the value.

Note: These flags take a Boolean value; it is only by coincidence that they can take the value of
the default month or day.

=head2 Why are dates returned as objects of type L<DateTime>?

Because such objects have the sophistication required to handle such a complex topic.

See L<DateTime> and L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

=head2 What happens if parse_date_period() is given a string like 'From 2000 to 1999'?

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

=item o Handle Gregorian years of the form 1699/00

See p. 65 of L<the GEDCOM Specification Ged551-5.pdf|http://wiki.webtrees.net/File:Ged551-5.pdf>.

=back

=head1 See Also

L<Genealogy::Gedcom>.

L<Gedcom::Date>.

=head1 Machine-Readable Change Log

The file Changes was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Repository

L<https://github.com/ronsavage/Genealogy-Gedcom-Date>.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Genealogy::Gedcom::Date>.

=head1 Thanx

Thanx to Eugene van der Pijll, the author of the Gedcom::Date::* modules.

Thanx also to the authors of the DateTime::* family of modules. See
L<http://datetime.perl.org/wiki/datetime/dashboard> for details.

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
