#!/usr/bin/perl

# Least number k such that both prime(k+1) -/+ prime(k) are products of n prime factors (counting multiplicity).
# https://oeis.org/A288507

# Known terms:
#   24, 319, 738, 57360, 1077529, 116552943

# Lower-bounds:
#   a(9) > pi(77309411327)

use 5.036;
use ntheory qw(:all);

my $n = 9;

my $diff = powint(2, $n);

my $lo = 2;
my $hi = 2*$lo;

while (1) {

    say "Sieving: [$lo, $hi]";

    foreach my $p (sieve_prime_cluster($lo, $hi, $diff)) {
        my $q = $p+$diff;

        if (is_almost_prime($n, $p+$q) and next_prime($p) == $q) {
        #if (next_prime($p) == $q and is_almost_prime($n, $p+$q)) {
            die "a($n) = ", prime_count($p), "\n";
        }
    }

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
a(8) = 116552943
perl x.sf  7.32s user 0.11s system 99% cpu 7.483 total
