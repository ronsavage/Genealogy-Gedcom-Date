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
	default  => sub{return 'Gregorian'},
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

	# Initialize the action class via global variables - Yuk!
	# The point is that we don't create an action instance.
	# Marpa creates one but we can't get our hands on it.

	my($calendar) =	$self -> calendar;
	$calendar     =~ s/\@\#d(.+)\@/$1/; # Zap gobbledegook if present.
	$calendar     = ucfirst lc $calendar;

	$self -> calendar($calendar);

	$Genealogy::Gedcom::Date::Actions::calendar = $calendar;
	$Genealogy::Gedcom::Date::Actions::logger   = $self -> logger;

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

calendar_escape			::=
calendar_escape			::= calendar_name 					action => calendar_name
							| ('@#d') calendar_name ('@')	action => calendar_name
							| ('@#D') calendar_name ('@')	action => calendar_name

calendar_date			::= gregorian_date				action => gregorian_date
							| julian_date				action => julian_date
							| french_date				action => french_date
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

year					::= number						action => year

french_date				::= day french_month_name year
							| year bce
							| year
							| french_month_name year

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

lds_ord_date			::= date_value

date_value				::= date_period
							| date_range
							| approximated_date
							| interpreted_date			action => interpreted_date
							| ('(') date_phrase (')')	action => date_phrase

date_period				::= from_date to_date
							| from_date
							| to_date

from_date				::= from date					action => from_date

to_date					::= to date			 			action => to_date

date_range				::= before date					action => before_date
							| after date				action => after_date
							| between date and date		action => between_date

approximated_date		::= about date					action => about_date
							| calculated date			action => calculated_date
							| estimated date			action => estimated_date

interpreted_date		::= interpreted date ('(') date_phrase (')')

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

french_month_name		~ 'vend':i | 'brum':i | 'frim':i | 'nivo':i | 'pluv':i | 'vent':i
							| 'germ':i | 'flor':i | 'prai':i | 'mess':i | 'ther':i
							| 'fruc':i | 'comp':i

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

sub clean_calendar
{
	my($self)     = @_;
	my($calendar) = $self -> calendar;
	$calendar     =~ s/\@\#d(.+)\@/$1/; # Zap gobbledegook if present.
	$calendar     = ucfirst lc $calendar;

	return $self -> calendar($calendar);

} # End of clean_calendar.

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
	my($calendar)    = defined($args{calendar}) ? $args{calendar} : $self -> calendar;
	my($date)        = defined($args{date}) ? $args{date} : $self -> date;
	$date            =~ tr/,/ /s;
	my($result)      = [];

	$self -> calendar($calendar);
	$self -> date($date);
	$self -> error('');
	$self -> recce
	(
		Marpa::R2::Scanless::R -> new
		({
			grammar           => $self -> grammar,
			ranking_method    => 'high_rule_only',
			semantics_package => 'Genealogy::Gedcom::Date::Actions',
		})
	);

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
			$result = $self -> process_unambiguous();
		}
		else
		{
			$result = $self -> process_ambiguous();
		}
	}
	catch
	{
		$self -> error($_);
	};

	$self -> log(debug => Dumper($result) );

	return $result;

} # End of parse.

# --------------------------------------------------

sub process_ambiguous
{
	my($self)     = @_;
	my($calendar) = $self -> clean_calendar;
	my(%count)    =
	(
		AND  => 0,
		BET  => 0,
		FROM => 0,
		TO   => 0,
	);
	my($result) = [];

	my($item);

	while (my $value = $self -> recce -> value)
	{
		$value = $self -> decode_result($$value);

		print STDERR 'Date: ', $self -> date, ". \n";
		print STDERR "Ambiguous: \n", Dumper($value);

		for $item (@$value)
		{
			if ($$item{kind} eq 'Calendar')
			{
				$calendar = $$item{type};

				next;
			}

			if ($calendar eq $$item{type})
			{
				# We have to allow for the fact that when 'From .. To' or 'Between ... And'
				# are used, both dates are ambiguous, and we end up with double the number
				# of elements in the arrayref compared to what's expected.

				if (exists $$item{flag} && exists $count{$$item{flag} })
				{
					if ($count{$$item{flag} } == 0)
					{
						$count{$$item{flag} }++;

						push @$result, $item;
					}
				}
				else
				{
					push @$result, $item;
				}
			}

			# Sometimes we must reverse the array elements.

			if ($#$result == 1)
			{
				if ( ($$result[0]{flag} eq 'AND') && ($$result[1]{flag} eq 'BET') )
				{
					($$result[0], $$result[1]) = ($$result[1], $$result[0]);
				}
				elsif ( ($$result[0]{flag} eq 'TO') && ($$result[1]{flag} eq 'FROM') )
				{
					($$result[0], $$result[1]) = ($$result[1], $$result[0]);
				}
			}

			# Reset the calendar. Note: The 'next' above skips this statement.

			$calendar = $self -> clean_calendar;
		}
	}

	return $result;

} # End of process_ambiguous.

# --------------------------------------------------

sub process_unambiguous
{
	my($self)     = @_;
	my($calendar) = $self -> clean_calendar;
	my($result)   = [];
	my($value)    = $self -> recce -> value;
	$value        = $self -> decode_result($$value);

	print STDERR 'Date: ', $self -> date, ". \n";
	print STDERR "Unambiguous: \n", Dumper($value);

	if ($#$value == 0)
	{
		print STDERR "0. \n";

		$value      = $$value[0];
		$$result[0] = $value if ($$value{type} =~ /^(?:$calendar|Phrase)$/);
	}
	elsif ($#$value == 2)
	{
		print STDERR "2. \n";

		$result = [$$value[0], $$value[1] ];
	}
	elsif ($#$value == 3)
	{
		print STDERR "3. \n";

		$result = [$$value[1], $$value[3] ];
	}
	elsif ($$value[0]{kind} eq 'Calendar')
	{
		print STDERR "kind. \n";

		$calendar = $$value[0]{type};

		if ($calendar eq $$value[1]{type})
		{
			$result = [$$value[1]];
		}
	}
	elsif ( ($$value[0]{type} eq $calendar) && ($$value[1]{type} eq $calendar) )
	{
		print STDERR "cal. \n";

		$result = $value;
	}

	return $result;

} # End of process_unambiguous.

# --------------------------------------------------

1;

=pod

=encoding utf8

=head1 NAME

Genealogy::Gedcom::Date - Parse GEDCOM dates

=head1 Synopsis

A script:

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

See scripts/synopsis.pl.

One-liners:

	perl -Ilib scripts/parse.pl -max debug -d 'Between Gregorian 1701/02 And Julian 1703'

Output:

	[
	  {
	    flag => "BET",
	    kind => "Date",
	    suffix => "02",
	    type => "Gregorian",
	    year => 1701
	  },
	  {
	    flag => "AND",
	    kind => "Date",
	    type => "Julian",
	    year => 1703
	  }
	]

	perl -Ilib scripts/parse.pl -max debug -d 'Int 10 Nov 1200 (Approx)'

Output:

	[
	  {
	    day => 10,
	    flag => "INT",
	    kind => "Date",
	    month => "Nov",
	    phrase => "(Approx)",
	    type => "Gregorian",
	    year => 1200
	  }
	]

	perl -Ilib scripts/parse.pl -max debug -d '(Unknown)'

	[
	  {
	    kind => "Phrase",
	    phrase => "(Unknown)",
	    type => "Phrase"
	  }
	]

See the L</FAQ> for the explanation of the output arrayrefs.

Lastly, you are I<strongly> encouraged to peruse t/English.t.

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
[e.g. L</date([$date])>]):

=over 4

=item o calendar => $name

The name (case-insensitive) of the calendar to use as the default.

Default: 'Gregorian' aka '@#dgregorian@'. Either format is acceptable.

=item o date => $date

The string to be parsed.

Each ',' is replaced by a space. See the L</FAQ> for details.

Default: ''.

=item o logger => $aLoggerObject

Specify a logger compatible with L<Log::Handler>, for the lexer and parser to use.

Default: A logger of type L<Log::Handler> which writes to the screen.

To disable logging, just set 'logger' to the empty string (not undef).

=item o maxlevel => $logOption1

This option affects L<Log::Handler>.

See the L<Log::Handler::Levels> docs.

By default nothing is printed.

Default: 'notice'.

=item o minlevel => $logOption2

This option affects L<Log::Handler>.

See the L<Log::Handler::Levels> docs.

Default: 'error'.

No lower levels are used.

=back

Note: The parameters C<calendar> and C<date> can also be passed to L</parse([%args])>.

=head1 Methods

=head2 calendar([$name])

Here, [ and ] indicate an optional parameter.

Gets or sets the name of the default calendar. $name is case-insensitive.

Calendar names of the form '@#d$name@' are converted internally into $name. This means you can
always just use $name, as in parse(date => 'Julian 1950').

That is: This module allows you to specify the calendar name without the Gedcom-mandated prefix and
suffix. Obviously, such a format will more likely not be acceptable to other software.

$name in C<< parse(calendar => $name) >> takes precedence over both C<< new(calendar => $name) >>
and C<calendar($name)>.

Also: If you call C<parse()> as C<< parse(calendar => $name) >>, then the value C<$name> is
stored so that if you subsequently call C<calendar()>, that value is returned.

See L</What extensions to the Gedcom grammar are supported?> for details.

See also L</What is the meaning of the 'calendar' key in method calls?>.

Note: C<calendar> is a parameter to new().

=head2 date([$date])

Here, [ and ] indicate an optional parameter.

Gets or sets the date to be parsed.

The date in C<< parse(date => $date) >> takes precedence over both C<< new(date => $date) >>
and C<date($date)>.

This means if you call C<parse()> as C<< parse(date => $date) >>, then the value C<$date> is stored
so that if you subsequently call C<date()>, that value is returned.

Note: C<date> is a parameter to new().

=head2 error()

Gets the last error message.

Returns '' (the empty string) if there have been no errors.

If L<Marpa::R2> throws an exception, it is caught by a try/catch block, and the C<Marpa> error
is returned by this method.

=head2 log($level, $s)

If a logger is defined, this logs the message $s at level $level.

=head2 logger([$logger_object])

Here, the [] indicate an optional parameter.

Get or set the logger object.

To disable logging, just set 'logger' to the empty string (not undef), in the call to L</new()>.

This logger is passed to other modules.

'logger' is a parameter to L</new()>. See L</Constructor and Initialization> for details.

=head2 maxlevel([$string])

Here, the [] indicate an optional parameter.

Get or set the value used by the logger object.

This option is only used if an object of type L<Log::Handler> is ceated.
See L<Log::Handler::Levels>.

Typical values are: 'notice', 'info', 'debug'. The default, 'notice', produces no output.

The code emits a message with log level 'error' if Marpa throws an exception, and it displays
the result of the parse at level 'debug' if maxlevel is set that high. The latter display uses
L<Data::Dumper::Concise>'s function Dumper().

'maxlevel' is a parameter to L</new()>. See L</Constructor and Initialization> for details.

=head2 minlevel([$string])

Here, the [] indicate an optional parameter.

Get or set the value used by the logger object.

This option is only used if an object of type L<Log::Handler> is created.
See L<Log::Handler::Levels>.

'minlevel' is a parameter to L</new()>. See L</Constructor and Initialization> for details.

=head2 new([%args])

The constructor. See L</Constructor and Initialization>.

=head2 parse([%args])

Here, [ and ] indicate an optional parameter.

C<parse()> returns an arrayref. See the L</FAQ> for details.

If the arrayref is empty, call L</error()> to retrieve the error message.

C<parse()> takes the same parameters as C<new()>.

Warning: The array can contain 1 element when 2 are expected. This can happen if your input contains
'From ... To ...' or 'Between ... And ...', and one of the dates is invalid. That is, the return
value from C<parse()> will contain the valid date but no indicator of the invalid one.

=head1 FAQ

=head2 Does this module accept Unicode?

Yes.

=head2 What is the format of the value returned by parse()?

It is always an arrayref.

If the date is like '1950' or 'Bef 1950 BCE', there will be 1 element in the arrayref.

If the date contains both 'From' and 'To', or both 'Between' and 'And', then the arrayref will
contain 2 elements.

Each element is a hashref, with various combinations of the following keys. You need to check the
existence of some keys before processing the date.

This means missing values (day, month, bce) are never fabricated. These keys only appear in the
hashref if such a token was found in the input.

Keys:

=over 4

=item o bce

If the input contains any one of the following (case-insensitive), the C<bce> key will be present:

=over 4

=item o 'bc'

=item o 'b.c'

=item o 'b.c.'

=item o 'bc.'

=item o 'b c'

=item o 'bce'

=back

=item o day => $integer

If the input contains a day, then the C<day> key will be present.

=item o flag => $string

If the input contains any of the following (case-insensitive), then the C<flag> key will be present:

=over 4

=item o Abt or About

=item o Aft or After

=item o And

=item o Bef or Before

=item o Bet or Between

=item o Cal or Calculated

=item o Est or Estimated

=item o From

=item o Int or Interpreted

=item o To

=back

$string will take one of these values (case-sensitive):

=over 4

=item o ABT

=item o AFT

=item o AND

=item o BEF

=item o BET

=item o CAL

=item o EST

=item o FROM

=item o INT

=item o TO

=back

=item o kind => 'Date' or 'Phrase'

The C<kind> key is always present, and always takes the value 'Date' or 'Phrase'.

If the value is 'Phrase', see the C<phrase> and C<type> keys.

During processing, there can be another - undocumented - element in the arrayref. It represents
the calendar escape, and in that case C<kind> takes the value 'Calendar'. This element is discarded
before the final arrayref is returned to the caller.

=item o month => $string

If the input contains a month, then the C<month> key will be present. The case of $string will be
exactly whatever was in the input.

=item o phrase => "($string)"

If the input contains a date phrase, then the C<phrase> key will be present. The case of $string
will be exactly whatever was in the input.

parse(date => 'Int 10 Nov 1200 (Approx)') returns:

	[
	  {
	    day => 10,
	    flag => "INT",
	    kind => "Date",
	    month => "Nov",
	    phrase => "(Approx)",
	    type => "Gregorian",
	    year => 1200
	  }
	]

parse(date => '(Unknown)') returns:

	[
	  {
	    kind => "Phrase",
	    phrase => "(Unknown)",
	    type => "Phrase"
	  }
	]

See also the C<kind> and C<type> keys.

=item o suffix => $two_digits

If the year contains a suffix (/00), then the C<suffix> key will be present. The '/' is
discarded.

Obviously, this key can only appear when the year is of the Gregorian form 1700/00.

See also the C<year> key below.

=item o type => $string

The C<type> key is always present, and takes one of these case-sensitive values:

=over 4

=item o Gregorian

=item o Julian

=item o Phrase

See also the C<kind> and C<phrase> keys.

=back

=item o year => $integer

If the input contains a year, then the C<year> key is present.

If the year contains a suffix (/00), see also the C<suffix> key, above. This means the value of
the C<year> key is never "$integer/$two_digits".

=back

=head2 What is the meaning of the 'calendar' key in method calls?

Possible values (case-insensitive):

=over 4

=item o calendar => 'French'

Expects dates in 'day month year' format, as in the Gedcom spec.

=item o calendar => 'German'

=item o calendar => 'Gregorian'

Expects dates in 'day month year' format, as in 'From 1 Jan 2001 to 31 Dec 2002'.

Expects years in either the 1950 format or the 1950/00 format.

This is the default.

=item o calendar => 'Hebrew'

Expects dates in 'day month year' format, as in the Gedcom spec.

=item o calendar => 'Julian'

Expects dates in 'day month year' format, as in 'From 1 Jan 2001 to 25 Dec 2002'.

Expects years in the 1950 format but never the (Gregorian) 1950/00 format.

=back

=head2 Are dates massaged before being processed?

Yes. Commas are replaced by spaces.

=head2 French month names

One of (case-insensitive):

'vend' | 'brum' | 'frim' | 'nivo' | 'pluv' | 'vent' | 'germ' | 'flor' | 'prai' | 'mess' | 'ther'
| 'fruc' | 'comp'.

=head2 German month names

One of (case-insensitive):

'jan' | 'feb' | 'mär' | 'maer' | 'mrz' | 'apr' | 'mai' | 'jun' | 'jul' | 'aug' | 'sep' | 'sept'
| 'okt' | 'nov' | 'dez'.

=head2 Hebrew month names

One of (case-insensitive):

'tsh' | 'csh' | 'ksl' | 'tvt' | 'shv' | 'adr' | 'ads' | 'nsn' | 'iyr' | 'svn' | 'tmz' |
'aav' | 'ell'

=head2 Your module rejected my date!

There are many possible reasons for this:

=over 4

=item o You mistyped the calendar escape

Check: Are any of these valid?

=over 4

=item o @#djulian

=item o @#julian@

=item o @#juliand

=item o @#djuliand

=item o @#dJulian@

=item o @#dJULIAN@

=back

Yes, the last 2 are valid.

=item o The date is in American format (month day year)

=item o You used a Julian calendar with a Gregorian year

Dates - such as 1900/01 - which do not fit the Gedcom definition of a Julian year, are filtered
out.

=back

=head2 What happens if C<parse()> is given a string like 'From 2000 to 1999'?

The code I<does not> reorder the dates.

=head2 Why was this module renamed from DateTime::Format::Gedcom?

The L<DateTime> suite of modules aren't designed, IMHO, for GEDCOM-like applications. It was a
mistake to use that name in the first place.

By releasing under the Genealogy::Gedcom::* namespace, I can be much more targeted in the data
types I choose as method return values.

=head2 Why did you choose Moo over Moose?

My policy is to use the lightweight L<Moo> for all modules and applications.

=head1 See Also

L<Genealogy::Gedcom>.

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
