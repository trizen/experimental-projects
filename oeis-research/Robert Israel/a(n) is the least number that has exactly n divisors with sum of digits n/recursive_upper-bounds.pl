#!/usr/bin/perl

# a(n) is the least number that has exactly n divisors with sum of digits n.
# https://oeis.org/A359444

use 5.020;
use warnings;
use experimental qw(signatures);

use ntheory qw(:all);
use Math::AnyNum qw(:overload);

sub smallest_number_with_n_divisors ($threshold, $least_solution = Inf, $k = 1, $max_a = Inf, $sigma0 = 1, $n = 1) {

    state $max = Inf;

    if ($sigma0 == $threshold) {
        if ($n < $max) {
            say "a($threshold) <= $n";
            $max = $n;
        }
        return $n;
    }

    if ($sigma0 > $threshold) {
        return $least_solution;
    }

    my $p = nth_prime($k);

    for (my $a = 1 ; $a <= $max_a ; ++$a) {
        $n *= $p;
        last if ($n > $least_solution);

        my $count = 0;
        foreach my $d (divisors($n)) {
            if (vecsum(todigits($d)) == $threshold) {
                ++$count;
            }
        }

        $least_solution = __SUB__->($threshold, $least_solution, $k + 1, $a, $count, $n);
    }

    return $least_solution;
}

my $n = 34;
say "a($n) <= ", smallest_number_with_n_divisors($n);

__END__
a(28) <= 8147739600
a(29) <= 7138971840
a(31) <= 37246809600
a(32) <= 37736899200
a(33) <= 1045524480
a(34) <= 25878772920
