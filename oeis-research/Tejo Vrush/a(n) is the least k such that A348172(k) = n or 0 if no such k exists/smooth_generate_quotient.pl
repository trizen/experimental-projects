#!/usr/bin/perl

# a(n) is the least k such that A348172(k) = n or 0 if no such k exists.
# https://oeis.org/A348184

# Known terms:
#   4, 1, 9, 243, 3189375, 3176523, 10598252544

# Conjectured upper-bounds:
#    a(8) <= 13011038208000
#   a(10) <= 1191916494900613125

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 5;
    }

    if ($p == 3) {
        return valuation($n, $p) < 3;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p < $limit) {    #and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

#my $h = smooth_numbers(1e10, primes(7));
my $h = smooth_numbers(6810951399432075+2, [2,3,5,7]);

#my $h = smooth_numbers(13011038208000 * 31 + 1, primes(31));

say "\nFound: ", scalar(@$h), " terms";

my %best;

foreach my $k (@$h) {

    #$k%2 == 0 or next;

    my %table;

    #for (my $i = 2; $i <= 10000; $i += 2) {
    for (my $i = 2; $i <= 1000; $i += 1) {

        my $n = mulint($i, $k);

        my $x = divisors($n);
        my $y = $n;

        my $g = gcd($x, $y);

        $x = divint($x, $g);
        $y = divint($y, $g);

        my $key = "$x/$y";

        $table{$key}{count}++;

        if (exists $table{$key}{max}) {
            if ($n < $table{$key}{max}) {
                $table{$key}{max} = $n;
            }
        }
        else {
            $table{$key}{max} = $n;
        }

        if ($table{$key}{count} >= 6) {

            if (exists $best{$table{$key}{count}}) {
                if ($table{$key}{max} < $best{$table{$key}{count}}) {
                    $best{$table{$key}{count}} = $table{$key}{max};
                    say "a($table{$key}{count}) = $best{$table{$key}{count}}";
                }
            }
            else {
                $best{$table{$key}{count}} = $table{$key}{max};
                say "a($table{$key}{count}) = $best{$table{$key}{count}}";
            }
        }
    }
}

__END__
a(6) <= 7962624
a(7) <= 362797056000
a(6) <= 3176523
a(8) <= 23544029528901
a(10) <= 1191916494900613125

a(6) <= 7962624
a(7) <= 362797056000
a(8) <= 13011038208000

a(6) <= 384521484375
a(7) <= 27751300048828125
a(6) <= 3176523
a(7) <= 689349609375
a(8) <= 23544029528901
a(10) = 1191916494900613125
