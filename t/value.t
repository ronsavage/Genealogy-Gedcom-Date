use strict;
use warnings;

use DateTime;
use DateTime::Infinite;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Date');}

my($locale) = 'en_AU';

DateTime -> DefaultLocale($locale);

my($past)   = DateTime::Infinite::Past -> new;
$past       = '-inf' if ($past eq '-1.#INF');
my($future) = DateTime::Infinite::Future -> new;
$future     = 'inf' if ($future eq '1.#INF');
my($parser) = Genealogy::Gedcom::Date -> new(debug => 1);

isa_ok($parser, 'Genealogy::Gedcom::Date');

my($date);
my($in_string);
my($out_string);

# Candidate value => Result hashref.

diag 'Start testing parse_date_value(...)';

my(%value) =
(
en_AU =>
{
		'(Unknown date)' => # Use parse_interpreted_date().
		{
		one               => $past,
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => $past,
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => 'unknown date',
		prefix            => '',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'Abt 1 Jan 2001' => # use parse_approximate_date().
		{
		one               => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2001, month => 1, day => 1),
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
		'Aft 1 Jan 2001' => # Use parse_date_range().
		{
		one               => DateTime -> new(year => 2001, month => 1, day => 1),
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2001, month => 1, day => 1),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'aft',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 0' => # Use parse_date_period().
		{
		one               => '0000-01-01T00:00:00',
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 1000),
		one_default_day   => 1,
		one_default_month => 1,
		phrase            => '',
		prefix            => 'from',
		two               => $future,
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => $future,
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$value{$locale} })
{
		$date = $parser -> parse_date_value(date => $candidate);

		$in_string  = join(', ', map{"$_ => '$value{$locale}{$candidate}{$_}'"} sort keys %{$value{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $value{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($value{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

done_testing;
