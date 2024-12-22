#!/usr/bin/perl

# a(n) is the least prime p such that p + 9*k*(k+1) is prime for 0 <= k <= n-1 but not for k=n.
# https://oeis.org/A378841

# Known terms:
#   2, 11, 13, 5, 19, 173, 3163, 83, 21013, 878359, 3676219, 239, 43

# New terms:
#   a(14) = 5201390418463
#   a(15) = 86927887467919

# Lower-bounds:
#   a(15) > 52776558133247

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2*$lo) {
    while (1) {
        say "Sieving for a($n): [$lo, $hi]";
        my @terms = grep { !is_prime($_ + 9 * $n * ($n + 1)) } sieve_prime_cluster($lo, $hi, map { 9 * $_ * ($_ + 1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.1 * $lo);
    }
}

my $lo = 1;
my $hi = int(1.1 * $lo);

say a(16, $lo, $hi);

#$| = 1;
#for my $n (1 .. 100) { say "a($n) = ", a($n); }
