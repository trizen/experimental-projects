#!/usr/bin/perl

# a(n) is the least prime p such that p + 8*k*(k+1) is prime for 0 <= k <= n-1 but not for k=n.
# https://oeis.org/A378839

# Known terms:
#   2, 3, 151, 181, 13, 811, 23671, 92221, 45417481, 5078503, 4861, 20379346831, 12180447943, 31

# New terms:
#   a(15) = 10347699089473

# Lower-bounds:
#   a(16) > 52776558133247

use 5.036;
use ntheory qw(:all);

sub a {
    my $n  = $_[0];
    my $lo = 2;
    my $hi = 2 * $lo;
    while (1) {
        say "Sieving: [$lo, $hi]";
        my @terms = grep { !is_prime($_ + 8 * $n * ($n + 1)) } sieve_prime_cluster($lo, $hi, map { 8 * $_ * ($_ + 1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = 2 * $lo;
    }
}

$| = 1;
for my $n (1 .. 100) { say "a($n) = ", a($n); }
