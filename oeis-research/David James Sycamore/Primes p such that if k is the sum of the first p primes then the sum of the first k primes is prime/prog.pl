#!/usr/bin/perl

# Primes p such that if k is the sum of the first p primes then the sum of the first k primes is prime.
# https://oeis.org/A321343

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

{
    my $prev_i;
    my $prev_p;

    sub after_prime1 {
        my ($n) = @_;

        if (not(defined($prev_i))) {

            $prev_i = $n;
            $prev_p = nth_prime($n);

            return $prev_p;
        }

        for (1 .. $n - $prev_i) {
            $prev_p = next_prime($prev_p);
        }

        $prev_i = $n;
        return $prev_p;
    }
}

{
    my $prev_i;
    my $prev_p;

    sub after_prime2 {
        my ($n) = @_;

        if (not(defined($prev_i))) {
            $prev_i = $n;
            $prev_p = nth_prime($n);

            return $prev_p;
        }

        for (1 .. $n - $prev_i) {
            $prev_p = next_prime($prev_p);
        }

        $prev_i = $n;
        return $prev_p;
    }
}

my $i = 1;
forprimes {

    my $k = $_;
    my $p = nth_prime(sum_primes_2(nth_prime($k)));
    my $sum = sum_primes_1($p);

    if (is_prime($sum)) {
        print "a($i) = $k\n";
        ++$i;
    }
} 1e7;
