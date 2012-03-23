use strict;
use warnings;

use DateTime;
use DateTime::Infinite;

use Test::More;

BEGIN {use_ok('Genealogy::Gedcom::Date');}

my($locale) = 'en_AU';

DateTime -> DefaultLocale($locale);

my($parser) = Genealogy::Gedcom::Date -> new(debug => 0);

isa_ok($parser, 'Genealogy::Gedcom::Date');

my($date);
my($in_string);
my($out_string);

# Candidate value => Result hashref.

diag "Start testing parse_date_period(...) with style 'american'";

my(%american_style) =
(
en_AU =>
{
		'From Jan 2 2011 BC to Mar 4 2011' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 1,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 3, day => 4),
		two_ambiguous     => 1,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 3, day => 4),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From Jan 2 2011 to Mar 4 2011' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 3, day => 4),
		two_ambiguous     => 1,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 3, day => 4),
		two_default_day   => 0,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$american_style{$locale} })
{
		$date       = $parser -> parse_date_period(date => $candidate, style => 'american');
		$in_string  = join(', ', map{"$_ => '$american_style{$locale}{$candidate}{$_}'"} sort keys %{$american_style{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $american_style{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($american_style{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

diag "Start testing parse_date_period(...) with style 'standard'";

my(%standard_style) =
(
en_AU =>
{
		'From 2011-01-02 to 2011-03-04' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 2),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 2),
		one_default_day   => 0,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 3, day => 4),
		two_ambiguous     => 1,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 3, day => 4),
		two_default_day   => 0,
		two_default_month => 0,
		},
		'From 2011 to 2012' =>
		{
		one               => DateTime -> new(year => 2011, month => 1, day => 1),
		one_ambiguous     => 0,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 1, day => 1),
		one_default_day   => 1,
		one_default_month => 1,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2012, month => 1, day => 1),
		two_ambiguous     => 0,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2012, month => 1, day => 1),
		two_default_day   => 1,
		two_default_month => 1,
		},
		'From 2011-10 to 2011-11' =>
		{
		one               => DateTime -> new(year => 2011, month => 10, day => 1),
		one_ambiguous     => 1,
		one_bc            => 0,
		one_date          => DateTime -> new(year => 2011, month => 10, day => 1),
		one_default_day   => 1,
		one_default_month => 0,
		phrase            => '',
		prefix            => 'from',
		two               => DateTime -> new(year => 2011, month => 11, day => 1),
		two_ambiguous     => 1,
		two_bc            => 0,
		two_date          => DateTime -> new(year => 2011, month => 11, day => 1),
		two_default_day   => 1,
		two_default_month => 0,
		},
}
);

for my $candidate (sort keys %{$standard_style{$locale} })
{
		$date       = $parser -> parse_date_period(date => $candidate, style => 'standard');
		$in_string  = join(', ', map{"$_ => '$standard_style{$locale}{$candidate}{$_}'"} sort keys %{$standard_style{$locale}{$candidate} });
		$out_string = join(', ', map{"$_ => '$$date{$_}'"} sort keys %$date);

		if ($parser -> debug)
		{
				for my $key (sort keys %$date)
				{
						diag "$key: In: $standard_style{$locale}{$candidate}{$key}. Out: $$date{$key}." if ($standard_style{$locale}{$candidate}{$key} ne $$date{$key});
				}
		}

		ok($in_string eq $out_string, "Testing: $candidate");
}

done_testing;
