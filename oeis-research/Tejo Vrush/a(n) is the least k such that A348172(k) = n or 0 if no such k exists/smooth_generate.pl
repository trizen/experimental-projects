#!/usr/bin/perl

# a(n) is the least k such that A348172(k) = n or 0 if no such k exists.
# https://oeis.org/A348184

# Known terms:
#   4, 1, 9, 243, 3189375, 3176523, 10598252544

# Conjectured upper-bounds:
#    a(8) <= 13011038208000
#   a(10) <= 1191916494900613125

# Verifying the a(8) bound would take around 17 hours using David A. Corneth's PARI program from https://oeis.org/A348172

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
            if ($n * $p < $limit) { #and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

my $h = smooth_numbers(~0, primes(19));
#my $h = smooth_numbers(13011038208000 * 31 + 1, primes(31));

say "\nFound: ", scalar(@$h), " terms";

my %table;
my %best;

foreach my $n (@$h) {

    #$n%2 == 0 or next;
    #valuation($n, 3) >= 8 or valuation($n, 2) >= 8 or next;

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
