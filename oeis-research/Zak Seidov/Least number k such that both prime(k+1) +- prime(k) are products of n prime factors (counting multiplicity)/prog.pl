#!/usr/bin/perl

# Least number k such that both prime(k+1) -/+ prime(k) are products of n prime factors (counting multiplicity).
# https://oeis.org/A288507

# Known terms:
#   24, 319, 738, 57360, 1077529, 116552943

# Lower-bounds:
#   a(9) > pi(51539607551)

use 5.036;
use ntheory qw(:all);

my $n = 9;
my $p = 51539607551;

my $diff = powint(2, $n);

forprimes {

    if ($_ - $p == $diff and is_almost_prime($n, $p+$_)) {
        die "a($n) = ", prime_count($p), "\n";
    }

    $p = $_;
} $p+1, 1e12;

__END__
a(8) = 116552943
perl x.sf  21.53s user 0.01s system 99% cpu 21.589 total

a(8) = 116552943
perl x.sf  9.46s user 0.04s system 95% cpu 9.990 total
