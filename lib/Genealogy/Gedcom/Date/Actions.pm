package Genealogy::Gedcom::Date::Actions;

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

our $DEBUG   = 0;
our $VERSION = '1.08';

# ------------------------------------------------

sub about_date
{
	my($cache, $t1, $t2) = @_;

	print 'about_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2         = $$t2[0];
	$$t2{about} = 'about';

	return $t2;

} # End of about_date.

# ------------------------------------------------

sub after_date
{
	my($cache, $t1, $t2) = @_;

	print 'after_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2         = $$t2[0];
	$$t2{after} = 'after';

	return $t2;

} # End of after_date.

# ------------------------------------------------

sub before_date
{
	my($cache, $t1, $t2) = @_;

	print 'before_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2          = $$t2[0];
	$$t2{before} = 'before';

	return $t2;

} # End of before_date.

# ------------------------------------------------

sub between_date
{
	my($cache, $t1, $t2, $t3, $t4) = @_;

	print 'between_date 2 => ', Dumper($t2) if ($DEBUG);
	print 'between_date 4 => ', Dumper($t4) if ($DEBUG);

	$t2           = $$t2[0];
	$$t2{between} = 'between';
	$t4           = $$t4[0];
	$$t4{and}     = 'and';

	return [$t2, $t4];

} # End of between_date.

# ------------------------------------------------

sub calculated_date
{
	my($cache, $t1, $t2) = @_;

	print 'calculated_date 1 => ', Dumper($t1) if ($DEBUG);
	print 'calculated_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2              = $$t2[0];
	$$t2{calculated} = 'calculated';

	return $t2;

} # End of calculated_date.

# ------------------------------------------------

sub date_phrase
{
	my($cache, $t1) = @_;

	print 'date_phrase 1 => ', Dumper($t1) if ($DEBUG);

	return $t1;

} # End of date_phrase.

# ------------------------------------------------

sub day
{
	my($cache, $t1) = @_;

	print 'day 1 => ', Dumper($t1) if ($DEBUG);

	return $t1;

} # End of day.

# ------------------------------------------------

sub estimated_date
{
	my($cache, $t1, $t2) = @_;

	print 'estimated_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2             = $$t2[0];
	$$t2{estimated} = 'estimated';

	return $t2;

} # End of estimated_date.

# ------------------------------------------------

sub from_date
{
	my($cache, $t1, $t2) = @_;

	print 'from_date 1 => ', Dumper($t1) if ($DEBUG);
	print 'from_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2        = $$t2[0];
	$$t2{from} = 'from';

	return $t2;

} # End of from_date.

# ------------------------------------------------

sub gregorian_date
{
	my($cache, $t1) = @_;

	print 'gregorian_date 1 => ' . Dumper($t1) if ($DEBUG);

	# Is it a BCE date? If so, it's already a hashref.

	if (ref($$t1[0]) eq 'HASH')
	{
		return $$t1[0];
	}

	my($year) = $$t1[2];

	if ($#$year > 0)
	{
		$year = "$$year[0]/$$year[1]";
	}
	else
	{
		$year = $$year[0];
	}

	return
	{
		day   => $$t1[0],
		month => $$t1[1],
		type  => 'gregorian',
		year  => $year,
	};

} # End of gregorian_date.

# ------------------------------------------------

sub gregorian_year_bce
{
	my($cache, $t1, $t2) = @_;

	print 'gregorian_year_bce 1 => ' . Dumper($t1) if ($DEBUG);
	print 'gregorian_year_bce 2 => ' . Dumper($t2) if ($DEBUG);

	return
	{
		bce  => $t2,
		type => 'gregorian_year',
		year => $$t1[0],
	};

} # End of gregorian_year_bce.

# ------------------------------------------------

sub interpreted_date
{
	my($cache, $t1, $t2) = @_;

	print 'interpreted_date 1 => ', Dumper($t1) if ($DEBUG);
	print 'interpreted_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2               = $$t2[0];
	$$t2{interpreted} = 'interpreted';

	return $t2;

} # End of interpreted_date.

# ------------------------------------------------

sub julian_date
{
	my($cache, $t1) = @_;

	# Is it a BCE date? If so, it's already a hashref.

	if (ref($$t1[0]) eq 'HASH')
	{
		return $$t1[0];
	}

	print 'julian_date 1 => ' . Dumper($t1) if ($DEBUG);

	my($year) = $$t1[2][0];

	return
	{
		day   => $$t1[0],
		month => $$t1[1],
		type  => 'julian',
		year  => $year,
	};

} # End of julian_date.

# ------------------------------------------------

sub julian_year_bce
{
	my($cache, $t1, $t2) = @_;

	print 'julian_year_bce 1 => ' . Dumper($t1) if ($DEBUG);
	print 'julian_year_bce 2 => ' . Dumper($t2) if ($DEBUG);

	return
	{
		bce  => $t2,
		type => 'julian_year',
		year => $t1,
	};

} # End of julian_year_bce.

# ------------------------------------------------

sub to_date
{
	my($cache, $t1, $t2) = @_;

	print 'to_date 1 => ', Dumper($t1) if ($DEBUG);
	print 'to_date 2 => ', Dumper($t2) if ($DEBUG);

	$t2      = $$t2[0];
	$$t2{to} = 'to';

	return $t2;

} # End of to_date.

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
