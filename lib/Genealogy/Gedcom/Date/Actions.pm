package Genealogy::Gedcom::Date::Actions;

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

our $VERSION = '1.08';

# ------------------------------------------------

sub calendar_date
{
	my($cache, $t1) = @_;

	print 'calendar_date: ' . Dumper($t1);

	return $t1;

} # End of calendar_date.

# ------------------------------------------------

sub date
{
	my($cache, $t1) = @_;

	print 'date: ' . Dumper($t1);

	return $t1;

} # End of date.

# ------------------------------------------------

sub gregorian_date
{
	my($cache, $t1) = @_;

	print 'gregorian_date: ' . Dumper($t1);

	return $t1;

} # End of gregorian_date.

# ------------------------------------------------

sub julian_date
{
	my($cache, $t1) = @_;

	print 'julian_date: ' . Dumper($t1);

	return $t1;

} # End of julian_date.

# ------------------------------------------------

sub lds_ord_date
{
	my($cache, $t1) = @_;

	print 'lds_ord_date: ' . Dumper($t1);

	return $t1;

} # End of lds_ord_date.

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
