#!/usr/bin/env perl

use strict;
use warnings;

use Genealogy::Gedcom::Date;

use Test::Stream -V1;

# ------------------------------------------------
# We have to find the words in %prefix, and put the calendar escape after each of them.

sub fix_date
{
	my($escape, $field) = @_;
	my(%prefix) =
	(
		AND  => 1,
		BET  => 1,
		FROM => 1,
		TO   => 1,
	);

	my(@result);

	for my $i (0 .. $#$field)
	{
		push @result, $$field[$i];
		push @result, $escape if (exists $prefix{$$field[$i]});
	}

	return join(' ', @result);

} # End of fix_date.

# ------------------------------------------------

my(@candidates) =
(
	{
		date   => '1950',
		result => [{kind => 'Date', type => 'Gregorian', year => '1950'}],
	},
	{
		date   => 'Jun 1950',
		result => [{kind => 'Date', type => 'Gregorian', month => 'Jun', year => '1950'}],
	},
	{
		date   => '21 Jun 1950',
		result => [{kind => 'Date', type => 'Gregorian', day => 21, month => 'Jun', year => '1950'}],
	},
	{
		date   => '1950/00',
		result => [{kind => 'Date', type => 'Gregorian',year => '1950/00'}],
	},
	{
		date   => 'Jun 1950/01',
		result => [{kind => 'Date', type => 'Gregorian', month => 'Jun', year => '1950/01'}],
	},
	{
		date   => '21 Jun 1950/02',
		result => [{kind => 'Date', type => 'Gregorian', day => 21, month => 'Jun', year => '1950/02'}],
	},
	{
		date   => '1950 BCE',
		result => [{bce => 'BCE', kind => 'Date', type => 'Gregorian', year => '1950'}],
	},
	{
		date   => '1950/03 BCE',
		result => [{bce => 'BCE', kind => 'Date', type => 'Gregorian',year => '1950/03'}],
	},
	{
		date   => 'Abt 1950',
		result => [{flag => 'ABT', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt Jun 1950',
		result => [{flag => 'ABT', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt 21 Jun 1950',
		result => [{day => 21, flag => 'ABT', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt 1950/04',
		result => [{flag => 'ABT', kind => 'Date', type => 'Gregorian',year => '1950/04'}],
	},
	{
		date   => 'Abt 1950 bc',
		result => [{bce => 'BCE', flag => 'ABT', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 1950',
		result => [{flag => 'AFT', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft Jun 1950',
		result => [{flag => 'AFT', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 21 Jun 1950',
		result => [{day => 21, flag => 'AFT', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 1950/05',
		result => [{flag => 'AFT', kind => 'Date', type => 'Gregorian',year => '1950/05'}],
	},
	{
		date   => 'Aft 1950 bc',
		result => [{bce => 'BCE', flag => 'AFT', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 1950',
		result => [{flag => 'BEF', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef Jun 1950',
		result => [{flag => 'BEF', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 21 Jun 1950',
		result => [{day => 21, flag => 'BEF', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 1950/06',
		result => [{flag => 'BEF', kind => 'Date', type => 'Gregorian',year => '1950/06'}],
	},
	{
		date   => 'Bef 1950 bc',
		result => [{bce => 'BCE', flag => 'BEF', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 1950',
		result => [{flag => 'CAL', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal Jun 1950',
		result => [{flag => 'CAL', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 21 Jun 1950',
		result => [{day => 21, flag => 'CAL', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 1950/07',
		result => [{flag => 'CAL', kind => 'Date', type => 'Gregorian',year => '1950/07'}],
	},
	{
		date   => 'Cal 1950 bc',
		result => [{bce => 'BCE', flag => 'CAL', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 1950',
		result => [{flag => 'EST', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est Jun 1950',
		result => [{flag => 'EST', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 21 Jun 1950',
		result => [{day => 21, flag => 'EST', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 1950/08',
		result => [{flag => 'EST', kind => 'Date', type => 'Gregorian',year => '1950/08'}],
	},
	{
		date   => 'Est 1950 bc',
		result => [{bce => 'BCE', flag => 'EST', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 1950',
		result => [{flag => 'FROM', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From Jun 1950',
		result => [{flag => 'FROM', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 21 Jun 1950',
		result => [{day => 21, flag => 'FROM', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 1950/09',
		result => [{flag => 'FROM', kind => 'Date', type => 'Gregorian',year => '1950/09'}],
	},
	{
		date   => 'From 1950 bc',
		result => [{bce => 'BCE', flag => 'FROM', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 1950',
		result => [{flag => 'TO', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To Jun 1950',
		result => [{flag => 'TO', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 21 Jun 1950',
		result => [{day => 21, flag => 'TO', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 1950/10',
		result => [{flag => 'TO', kind => 'Date', type => 'Gregorian',year => '1950/10'}],
	},
	{
		date   => 'To 1950 bc',
		result => [{bce => 'BCE', flag => 'TO', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Between 1950 and 1956',
		result =>
		[
			{flag => 'BET', kind => 'Date', type => 'Gregorian',year => '1950'},
			{flag => 'AND', kind => 'Date', type => 'Gregorian',year => '1956'},
		],
	},
	{
		date   => 'From 1950 to 1956',
		result =>
		[
			{flag => 'FROM', kind => 'Date', type => 'Gregorian',year => '1950'},
			{flag => 'TO',   kind => 'Date', type => 'Gregorian',year => '1956'},
		],
	},
);

my($parser) = Genealogy::Gedcom::Date -> new;
my(%prefix) =
(
	ABT => 1,
	AFT => 1,
	BEF => 1,
	CAL => 1,
	EST => 1,
	INT => 1,
);

my($date);
my(@field);
my($message);
my($result);
my($temp_date);

for my $calendar ('', 'Gregorian', 'Julian')
{
	for my $item (@candidates)
	{
		$date = $$item{date};

		next if ( ($calendar eq 'Julian') && ($date =~ m|/|) );

		$message = "English. Date: $date";

		if ($calendar)
		{
			# This must not be inside the next loop as calendar($escape).
			# The Perl code only uses 'Gregorian' and 'Julian'.

			$parser -> calendar($calendar);

			if ($#{$$item{result} } == 0)
			{
				$$item{result}[0]{type} = $calendar;
			}
			else
			{
				$$item{result}[0]{type} = $calendar;
				$$item{result}[1]{type} = $calendar;
			}

			for my $escape ($calendar, "\@#d$calendar\@")
			{
				# We can't just include '@#d' in $message, because then Test::Stream aborts.

				if ($escape eq $calendar)
				{
					$message = "English. Date: $date. Calendar: $calendar";
				}
				else
				{
					$message = "English. Date: $date. Calendar: \@!d$calendar\@ (Test::Stream rejects cross-hatch!)";
				}

				@field = split(/\s+/, $date);

				# Splice the calendar escape into the date.

				if (uc($field[0]) =~ /FROM|BET|TO/)
				{
					$temp_date = fix_date(lc $escape, \@field);
				}
				elsif (exists $prefix{uc $field[0]})
				{
					$temp_date = join(' ', $field[0], lc $escape, @field[1 .. $#field]);
				}
				else
				{
					$temp_date = "$escape $date";
				}

				$result = $parser -> parse(date => $temp_date);

				is($result, $$item{result}, $message);
			}
		}
		else
		{
			$result = $parser -> parse(date => $date);

			is($result, $$item{result}, $message);
		}
	}
}

done_testing;
