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
		'Abt @#DGregorian@ 2 Jan 2001' =>
		{
		one               => DateTime -> new(year => 2001, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2001, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'abt',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Est @#DGregorian@ 2 Feb 2000' =>
		{
		one               => DateTime -> new(year => 2000, month => 2, day => 2),
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2000, month => 2, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'est',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
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

my(%date_period) =
(
en_AU =>
{
		'From @#DGregorian@ 2 Jan 2000' =>
		{
		one               => DateTime -> new(year => 2000, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2000, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From @#DGregorian@ 2 Jan 2011 to 3 Mar 2011' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 3, day => 3),
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 3, day => 3),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From @#DGregorian@ 1 January 2000' =>
		{
		one               => DateTime -> new(year => 2000, month => 1, day => 1),
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2000, month => 1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From @#DGregorian@ 2 January 2011' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From @#DGregorian@ 2 January 2011 to 25 Dec 2011' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 12, day => 25),
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 12, day => 25),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'To 25 Dec 2011' => # Missing escape defaults to Gregorian.
		{
		one               => $past,
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => '-inf',
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'to',
		two               => DateTime -> new(year => 2011, month => 12, day => 25),
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 12, day => 25),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'To @#DGregorian@ 25 Dec 2011' =>
		{
		one               => $past,
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => '-inf',
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'to',
		two               => DateTime -> new(year => 2011, month => 12, day => 25),
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 12, day => 25),
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$date_period{$locale} })
{
		$date       = $parser -> parse_date_period(date => $candidate);
		$in_string  = join(', ', map{"$_ => '$date_period{$locale}{$candidate}{$_}'"} sort keys %{$date_period{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				diag "In:  $in_string.";
				diag "Out: $out_string";
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

done_testing;
