#!/usr/bin/perl

# a(1)=1; for n > 1, a(n) is the smallest number with the same number of divisors as 2*a(n-1).
# https://oeis.org/A019505

use 5.020;
use warnings;
use experimental qw(signatures);

use ntheory qw(nth_prime divisor_sum);
use Math::AnyNum qw(:overload lcm);

sub smallest_number_with_n_divisors ($threshold, $least_solution = Inf, $k = 1, $max_a = Inf, $solutions = 1, $n = 1) {

    if ($solutions == $threshold) {
        return $n;
    }

    if ($solutions > $threshold) {
        return $least_solution;
    }

    my $p = nth_prime($k);

    for (my $a = 1 ; $a <= $max_a ; ++$a) {
        $n *= $p;
        last if ($n > $least_solution);
        $least_solution = __SUB__->($threshold, $least_solution, $k + 1, $a, $solutions * ($a + 1), $n);
    }

    return $least_solution;
}

my $u = 1;

say "1 $u";

foreach my $n (2..1000) {
    my $sigma0 = divisor_sum(2*$u, 0);
    my $v = smallest_number_with_n_divisors($sigma0);
    say "$n $v";
    $u = $v;
}
