#!/usr/bin/perl

# Least prime p such that the n smallest primitive roots modulo p are the first n primes.
# https://oeis.org/A355016

# Known terms:
#    3, 5, 53, 173, 2083, 188323, 350443, 350443, 1014787, 29861203, 154363267

# Try to find an upper-bound for a(12), by generating primes of the form k*p + 1, where k is small and p is prime.

# No upper-bound for a(12) is currently known.

use 5.036;
use ntheory qw(:all);

my $n = 12;
my @primes = @{primes(nth_prime($n))};

sub isok($p) {
    foreach my $q (@primes) {
        is_primitive_root($q, $p)
            or return;
    }
    foreach my $c (4..$primes[-1]-1) {
        is_prime($c) && next;
        is_primitive_root($c, $p)
            and return;
    }
    return 1;
}

foreach my $k((
    #1, 2, 4, 6, 18, 54, 1722
    #162, 282, 1026, 1062, 1842, 2358, 10206, 28746, 62514, 108918, 235962
    124, 164, 292, 316, 356, 404, 428, 628, 1252, 7628, 10196, 11812, 21188, 31804, 404356, 1031036
)) {
    say "Checking: $k";
    forprimes {
        my $p = $k*$_ + 1;

        if (is_prime($p)) {
            while (isok($p)) {
                say "a($n) = $p";
                ++$n;
                push @primes, next_prime($primes[-1]);
            }
        }
    } 1e9;
}
