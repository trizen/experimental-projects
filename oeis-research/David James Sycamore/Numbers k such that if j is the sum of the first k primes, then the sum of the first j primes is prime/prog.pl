#!/usr/bin/perl

# Numbers k such that if j is the sum of the first k primes, then the sum of the first j primes is prime.
# https://oeis.org/A321342

use 5.014;
use ntheory qw(:all);
use Math::AnyNum qw(:overload);

{
    my $prev_p;
    my $prev_sum;

    sub sum_primes_1 {
        my ($n) = @_;

        if (not defined($prev_p)) {
            $prev_p   = $n;
            $prev_sum = 0 + sum_primes($n);
            return $prev_sum;
        }

        $prev_sum += sum_primes($prev_p + 1, $n);
        $prev_p = $n;

        return $prev_sum;
    }

}

{
    my $prev_p;
    my $prev_sum;

    sub sum_primes_2 {
        my ($n) = @_;

        if (not defined($prev_p)) {
            $prev_p   = $n;
            $prev_sum = 0 + sum_primes($n);
            return $prev_sum;
        }

        $prev_sum += sum_primes($prev_p + 1, $n);
        $prev_p = $n;

        return $prev_sum;
    }
}

my $i = 1;
for (my $k = 1 ;; $k+=2) {

    my $p = nth_prime(sum_primes_2(nth_prime($k)));
    my $sum = sum_primes_1($p);

    if (is_prime($sum)) {
        print "a($i) = $k\n";
        ++$i;
    }
}
