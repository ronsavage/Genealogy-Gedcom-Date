use strict;
use warnings;

use DateTime;
use DateTime::Infinite;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Date');}

my($locale) = 'en_AU';

DateTime -> DefaultLocale($locale);

my($past)   = DateTime::Infinite::Past -> new;
$past       = '-inf' if ( ($past eq '-1.#INF') || ($past eq '-Infinity') );
my($future) = DateTime::Infinite::Future -> new;
$future     = 'inf' if ( ($future eq '1.#INF') || ($future eq 'Infinity') );
my($parser) = Genealogy::Gedcom::Date -> new(debug => 0);

isa_ok($parser, 'Genealogy::Gedcom::Date');

my($date);
my($in_string);
my($out_string);

# Candidate value => Result hashref.

diag 'Start testing parse_approximate_date(...)';

my(%approximate) =
(
en_AU =>
{
		'Abt 1 Jan 2001' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month => 1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'abt',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Abt 4000 BC' =>
		{
		one           => DateTime -> new(year => 4000, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 4000, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'abt',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Cal 2345 BC' =>
		{
		one           => DateTime -> new(year => 2345, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 2345, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'cal',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Cal 31 Dec 2000' =>
		{
		one           => DateTime -> new(year => 2000, month => 12, day => 31),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2000, month => 12, day => 31),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'cal',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Est 1 Jan 2001' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month =>  1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'est',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Est 1234BC' =>
		{
		one           => DateTime -> new(year => 1234, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1234, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'est',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$approximate{$locale} })
{
		$date = $parser -> parse_approximate_date(date => $candidate, prefix => ['Abt', 'Cal', 'Est']);

		$in_string  = join(', ', map{"$_ => '$approximate{$locale}{$candidate}{$_}'"} sort keys %{$approximate{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $approximate{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($approximate{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

diag 'Start testing parse_date_period(...)';

my(%period) =
(
en_AU =>
{
		'From 0' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1000),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 0 BC' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1000),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 0 to 99' =>
		{
		one           => '0000-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1000),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => '0099-01-01T00:00:00',
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 1099),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'From 1 Jan 2001 to 25 Dec 2002' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month =>  1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'from',
		two           => DateTime -> new(year => 2002, month => 12, day => 25),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2002, month => 12, day => 25),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 25 Dec 2002 to 1 Jan 2001' => # A retrograde example.
		{
		one           => DateTime -> new(year => 2002, month => 12, day => 25),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2002, month => 12, day => 25),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'from',
		two           => DateTime -> new(year => 2001, month =>  1, day => 1),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2001, month => 1, day => 1),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 2011' =>
		{
		one           => DateTime -> new(year => 2011),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2011),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 21 Jun 6004BC.' =>
		{
		one           => DateTime -> new(year => 6004, month => 6, day => 21),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 6004, month => 6, day => 21),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 500B.C.' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 500BC' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 500BC to 400' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => '0400-01-01T00:00:00',
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 1400),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'From 500BC to 400BCE' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => '0400-01-01T00:00:00',
		two_ambiguous => 0,
		two_bc        => 1,
		two_date      => DateTime -> new(year => 1400),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'From 500BC.' =>
		{
		one           => '0500-01-01T00:00:00',
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1500),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'from',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From Nov 2011 to Dec 2011' =>
		{
		one           => DateTime -> new(year => 2011, month => 11, day => 1),
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2011, month => 11, day => 1),
		one_default_day   => 1,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'from',
		two           => DateTime -> new(year => 2011, month => 12, day => 1),
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2011, month => 12, day => 1),
		two_default_day   => 1,
		two_default_month => 0,
		},
		'To 2011' =>
		{
		one           => $past,
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => $past,
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'to',
		two           => DateTime -> new(year => 2011),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2011),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'To 500 BC' =>
		{
		one           => $past,
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => $past,
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'to',
		two           => '0500-01-01T00:00:00',
		two_ambiguous => 0,
		two_bc        => 1,
		two_date      => DateTime -> new(year => 1500),
		two_default_day   => 1,
		two_default_month => 1,
		},
}
);

for my $candidate (sort keys %{$period{$locale} })
{
		$date       = $parser -> parse_date_period(date => $candidate);
		$in_string  = join(', ', map{"$_ => '$period{$locale}{$candidate}{$_}'"} sort keys %{$period{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $period{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($period{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

diag 'Start testing parse_date_range(...)';

my(%range) =
(
en_AU =>
{
		'Aft 1 Jan 2001' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month => 1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'aft',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Aft 4000 BC' =>
		{
		one           => DateTime -> new(year => 4000, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 4000, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'aft',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Bef 2345 BC' =>
		{
		one           => DateTime -> new(year => 2345, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 2345, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'bef',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Bef 31 Dec 2000' =>
		{
		one           => DateTime -> new(year => 2000, month => 12, day => 31),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2000, month => 12, day => 31),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'bef',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Bet 1 Jan 2001 and 25 Dec 2002' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month =>  1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'bet',
		two           => DateTime -> new(year => 2002, month => 12, day => 25),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2002, month => 12, day => 25),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Bet 1234BC and 5678' =>
		{
		one           => DateTime -> new(year => 1234, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 1234, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => '',
		prefix        => 'bet',
		two           => DateTime -> new(year => 5678, month => 1, day => 1),
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 5678, month => 1, day => 1),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'Bet Nov 2011 and Dec 2011' =>
		{
		one           => DateTime -> new(year => 2011, month => 11, day => 1),
		one_ambiguous => 1,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2011, month => 11, day => 1),
		one_default_day   => 1,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'bet',
		two           => DateTime -> new(year => 2011, month => 12, day => 1),
		two_ambiguous => 1,
		two_bc        => 0,
		two_date      => DateTime -> new(year => 2011, month => 12, day => 1),
		two_default_day   => 1,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$range{$locale} })
{
		$date = $parser -> parse_date_range(date => $candidate, from_to => [ ['Aft', 'Bef', 'Bet'] , 'And']);

		$in_string  = join(', ', map{"$_ => '$range{$locale}{$candidate}{$_}'"} sort keys %{$range{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $range{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($range{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

diag 'Start testing parse_datetime(...)';

my(%datetime) =
(
en_AU =>
{
		'21 Jun 1950' =>
		{
		one           => DateTime -> new(year => 1950, month => 6, day => 21),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 1950, month => 6, day => 21),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => '',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$datetime{$locale} })
{
		$date = $parser -> parse_datetime($candidate);

		$in_string  = join(', ', map{"$_ => '$datetime{$locale}{$candidate}{$_}'"} sort keys %{$datetime{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $datetime{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($datetime{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

diag 'Start testing parse_interpreted_date(...)';

my(%interpreted) =
(
en_AU =>
{
		'(Unknown date)' =>
		{
		one           => $past,
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => $past,
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => 'unknown date',
		prefix        => '',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Int 1 Jan 2001' =>
		{
		one           => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 0,
		one_date      => DateTime -> new(year => 2001, month => 1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase        => '',
		prefix        => 'int',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'int 4000 BC (more or less)' =>
		{
		one           => DateTime -> new(year => 4000, month => 1, day => 1),
		one_ambiguous => 0,
		one_bc        => 1,
		one_date      => DateTime -> new(year => 4000, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase        => 'more or less',
		prefix        => 'int',
		two           => $future,
		two_ambiguous => 0,
		two_bc        => 0,
		two_date      => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$interpreted{$locale} })
{
		$date = $parser -> parse_interpreted_date(date => $candidate, prefix => 'Int');

		$in_string  = join(', ', map{"$_ => '$interpreted{$locale}{$candidate}{$_}'"} sort keys %{$interpreted{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $interpreted{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($interpreted{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

done_testing;
