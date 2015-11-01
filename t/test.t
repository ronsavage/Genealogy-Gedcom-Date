#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper::Concise; # For Dumper().

use Genealogy::Gedcom::Date;

use Test::Stream -V1;

# -------------------------

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
		result => [{flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt Jun 1950',
		result => [{flag => 'About', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt 21 Jun 1950',
		result => [{day => 21, flag => 'About', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Abt 1950/04',
		result => [{flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950/04'}],
	},
	{
		date   => 'Abt 1950 bc',
		result => [{bce => 'BCE', flag => 'About', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 1950',
		result => [{flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft Jun 1950',
		result => [{flag => 'After', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 21 Jun 1950',
		result => [{day => 21, flag => 'After', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Aft 1950/05',
		result => [{flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950/05'}],
	},
	{
		date   => 'Aft 1950 bc',
		result => [{bce => 'BCE', flag => 'After', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 1950',
		result => [{flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef Jun 1950',
		result => [{flag => 'Before', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 21 Jun 1950',
		result => [{day => 21, flag => 'Before', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Bef 1950/06',
		result => [{flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950/06'}],
	},
	{
		date   => 'Bef 1950 bc',
		result => [{bce => 'BCE', flag => 'Before', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 1950',
		result => [{flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal Jun 1950',
		result => [{flag => 'Calculated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 21 Jun 1950',
		result => [{day => 21, flag => 'Calculated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Cal 1950/07',
		result => [{flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950/07'}],
	},
	{
		date   => 'Cal 1950 bc',
		result => [{bce => 'BCE', flag => 'Calculated', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 1950',
		result => [{flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est Jun 1950',
		result => [{flag => 'Estimated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 21 Jun 1950',
		result => [{day => 21, flag => 'Estimated', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'Est 1950/08',
		result => [{flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950/08'}],
	},
	{
		date   => 'Est 1950 bc',
		result => [{bce => 'BCE', flag => 'Estimated', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 1950',
		result => [{flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From Jun 1950',
		result => [{flag => 'From', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 21 Jun 1950',
		result => [{day => 21, flag => 'From', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'From 1950/09',
		result => [{flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950/09'}],
	},
	{
		date   => 'From 1950 bc',
		result => [{bce => 'BCE', flag => 'From', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 1950',
		result => [{flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To Jun 1950',
		result => [{flag => 'To', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 21 Jun 1950',
		result => [{day => 21, flag => 'To', kind => 'Date', month => 'Jun', type => 'Gregorian',year => '1950'}],
	},
	{
		date   => 'To 1950/10',
		result => [{flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950/10'}],
	},
	{
		date   => 'To 1950 bc',
		result => [{bce => 'BCE', flag => 'To', kind => 'Date', type => 'Gregorian',year => '1950'}],
	},
);

my($parser) = Genealogy::Gedcom::Date -> new;
my(%prefix) =
(
	Abt  => 1,
	Aft  => 1,
	Bef  => 1,
	Cal  => 1,
	Est  => 1,
	From => 1,
	To   => 1,
);

my($date);
my(@field);
my($message);
my($result);

for my $calendar ('', 'Gregorian', 'Julian')
{
	for my $item (@candidates)
	{
		$date = $$item{date};

		next if ( ($calendar eq 'Julian') && ($date =~ m|/|) );

		$message = "Date: $date";

		if ($calendar)
		{
			$parser -> calendar($calendar);

			$message                .= ". Calendar: $calendar";
			$$item{result}[0]{type} = $calendar;
			@field                  = split(/\s+/, $date);

			if ($prefix{$field[0]})
			{
				$date = join(' ', $field[0], "\@#d$calendar\@", @field[1 .. $#field]);
			}
		}

		$result = $parser -> parse(date => $date);

		is($result, $$item{result}, $message);
	}
}

done_testing;
