package Genealogy::Gedcom::Date::Actions;

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

our $logger;

our $VERSION = '1.08';

# ------------------------------------------------

sub about_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'about_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'about_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'ABT';

	return $t2;

} # End of about_date.

# ------------------------------------------------

sub after_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'after_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'after_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'AFT';

	return $t2;

} # End of after_date.

# ------------------------------------------------

sub before_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'after_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'before_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'BEF';

	return $t2;

} # End of before_date.

# ------------------------------------------------

sub between_date
{
	my($cache, $t1, $t2, $t3, $t4) = @_;

	$logger -> log(debug => 'between_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'between_date 2 => ' . Dumper($t2) );
	$logger -> log(debug => 'between_date 3 => ' . Dumper($t3) );
	$logger -> log(debug => 'between_date 4 => ' . Dumper($t4) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'BET';
	$t4        = $$t4[1];
	$t4        = $$t4[0] if (ref $t4 eq 'ARRAY');
	$$t4{flag} = 'AND';

	return [$t2, $t4];

} # End of between_date.

# ------------------------------------------------

sub calculated_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'calculated_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'calculated_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'CAL';

	return $t2;

} # End of calculated_date.

# ------------------------------------------------

sub calendar_name
{
	my($cache, $t1) = @_;
	$t1 = ucfirst lc $t1;

	$logger -> log(debug => 'calendar_name 1 => ' . Dumper($t1) );

	return
	{
		kind => 'Calendar',
		type => $t1,
	};

} # End of calendar_name.

# ------------------------------------------------

sub date_phrase
{
	my($cache, $t1, $t2, $t3) = @_;

	$logger -> log(debug => 'date_phrase 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'date_phrase 2 => ' . Dumper($t2) );
	$logger -> log(debug => 'date_phrase 3 => ' . Dumper($t3) );

	return
	{
		phrase => "$t1$$t2[0]$t3"
	};

} # End of date_phrase.

# ------------------------------------------------

sub day
{
	my($cache, $t1) = @_;

	$logger -> log(debug => 'day 1 => ' . Dumper($t1) );

	return $t1;

} # End of day.

# ------------------------------------------------

sub estimated_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'estimated_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'EST';

	return $t2;

} # End of estimated_date.

# ------------------------------------------------

sub from_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'from_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'from_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'FROM';

	return $t2;

} # End of from_date.

# ------------------------------------------------

sub gregorian_date
{
	my($cache, $t1) = @_;

	$logger -> log(debug => 'gregorian_date 1 => ' . Dumper($t1) );

	# Is it a BCE date? If so, it's already a hashref.

	if (ref($$t1[0]) eq 'HASH')
	{
		$$t1[0]{bce} = 'BCE';

		return $$t1[0];
	}

	my($day);
	my($month);
	my($year);

	# Check for year, month, day.

	if ($#$t1 == 0)
	{
		$year = $$t1[0];
	}
	elsif ($#$t1 == 1)
	{
		$month = $$t1[0];
		$year  = $$t1[1];
	}
	else
	{
		$day   = $$t1[0];
		$month = $$t1[1];
		$year  = $$t1[2];
	}

	my($result) =
	{
		kind  => 'Date',
		type  => 'Gregorian',
		year  => $year,
	};

	# Check for /00.

	if ($#$t1 == 3)
	{
		$$result{year}   = $$year[0];
		$$result{suffix} = $$year[1];
	}

	$$result{month} = $month if (defined $month);
	$$result{day}   = $day   if (defined $day);
	$result         = [$result];

	return $result;

} # End of gregorian_date.

# ------------------------------------------------

sub gregorian_month
{
	my($cache, $t1) = @_;

	$logger -> log(debug => 'gregorian_month 1 => ' . Dumper($t1) );

	if (ref $t1)
	{
		return $$t1[0];
	}
	else
	{
		return $t1;
	}

} # End of gregorian_month.

# ------------------------------------------------

sub gregorian_year_bce
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'gregorian_year_bce 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'gregorian_year_bce 2 => ' . Dumper($t2) );

	return
	{
		bce  => uc $t2,
		kind => 'Date',
		type => 'Gregorian',
		year => $t1,
	};

} # End of gregorian_year_bce.

# ------------------------------------------------

sub interpreted_date
{
	my($cache, $t1) = @_;

	$logger -> log(debug => 'interpreted_date 1 => ' . Dumper($t1) );

	my($t2)      = $$t1[1][0];
	$$t2{flag}   = 'INT';
	$$t2{phrase} = "$$t1[2]$$t1[3][0]$$t1[4]";

	return $t2;

} # End of interpreted_date.

# ------------------------------------------------

sub julian_date
{
	my($cache, $t1) = @_;

	$logger -> log(debug => 'julian_date 1 => ' . Dumper($t1) );

	# Is it a BCE date? If so, it's already a hashref.

	if (ref($$t1[0]) eq 'HASH')
	{
		$$t1[0]{bce} = 'BCE';

		return $$t1[0];
	}

	$logger -> log(debug => 'julian_date shift 1 => ' . Dumper($t1) );

	my($day);
	my($month);
	my($year);

	# Check for year, month, day.

	if ($#$t1 == 0)
	{
		$year = $$t1[0];
	}
	elsif ($#$t1 == 1)
	{
		$month = $$t1[0];
		$year  = $$t1[1];
	}
	else
	{
		$day   = $$t1[0];
		$month = $$t1[1];
		$year  = $$t1[2];
	}

	my($result) =
	{
		kind  => 'Date',
		type  => 'Julian',
		year  => $year,
	};

	$$result{month} = $month if (defined $month);
	$$result{day}   = $day if (defined $day);
	$result         = [$result];

	return $result;

} # End of julian_date.

# ------------------------------------------------

sub julian_year_bce
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'julian_year_bce 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'julian_year_bce 2 => ' . Dumper($t2) );

	return
	{
		bce  => $t2,
		kind => 'Date',
		type => 'Julian',
		year => $t1,
	};

} # End of julian_year_bce.

# ------------------------------------------------

sub to_date
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'to_date 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'to_date 2 => ' . Dumper($t2) );

	$t2        = $$t2[1];
	$t2        = $$t2[0] if (ref $t2 eq 'ARRAY');
	$$t2{flag} = 'TO';

	return $t2;

} # End of to_date.

# ------------------------------------------------

sub year
{
	my($cache, $t1, $t2) = @_;

	$logger -> log(debug => 'year 1 => ' . Dumper($t1) );
	$logger -> log(debug => 'year 2 => ' . Dumper($t2) );

	my($result);

	if (defined $t2)
	{
		$result = "$t1/$t2";
	}
	else
	{
		$result = $t1;
	}

	return $result;

} # End of year.

# ------------------------------------------------

1;

=pod

=head1 NAME

C<Genealogy::Gedcom::Date::Actions> - A nested SVG parser, using XML::SAX and Marpa::R2

=head1 Synopsis

See L<Genealogy::Gedcom::Date/Synopsis>.

=head1 Description

Basically just utility routines for L<Genealogy::Gedcom::Date>. Only used indirectly by L<Marpa::R2>.

Specifially, calls to functions are triggered by items in the input stream matching elements of the current
grammar (and Marpa does the calling).

Each action function returns a hashref, which Marpa gathers. The calling code
L<Genealogy::Gedcom::Date> decodes the result and puts the hashrefs into a stack, described in
the L<Genealogy::Gedcom::Dater/FAQ>.

=head1 Installation

See L<Genealogy::Gedcom::Date/Installation>.

=head1 Constructor and Initialization

This class has no constructor. L<Marpa::R2> fabricates an instance, but won't let us get access to it.

So, we use a global variable, C<$logger>, initialized in L<Genealogy::Gedcom::Date>,
in case we need logging. Details:

=over 4

=item o logger => aLog::HandlerObject

By default, an object of type L<Log::Handler> is created which prints to STDOUT,
but given the default, nothing is actually printed unless the C<maxlevel> attribute of this object is changed
in L<Genealogy::Gedcom::Date>.

Default: anObjectOfTypeLogHandler.

=back

Also, each new parse is preceeded by a call to the L</init()> function, to reset some counters global to this file.

=head1 Methods

None.

=head1 Functions

=head2 boolean($t1)

Returns a hashref identifying the boolean $t1.

=head2 command($t1, @t2)

Returns a hashref identifying the command $t1 and its parameters in @t2.

=head2 float($t1)

Returns a hashref identifying the float $t1.

=head2 init()

Resets some counters global to the file. This must be called at the start of each new parse.

=head2 integer($t1)

Returns a hashref identifying the integer $t1.

=head2 log($level, $s)

Calls $logger -> log($level => $s) if ($logger).

=head2 string($t1)

Returns a hashref identifying the string $t1.

=head1 FAQ

See L<Genealogy::Gedcom::Date/FAQ>.

=head1 Author

L<Genealogy::Gedcom::Date> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: L<http://savage.net.au/>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License 2.0, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
