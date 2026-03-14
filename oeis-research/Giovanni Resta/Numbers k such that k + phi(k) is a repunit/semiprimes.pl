#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 14 March 2026
# https://github.com/trizen

# Numbers k such that k + phi(k) is a repunit.
# https://oeis.org/A309835

use 5.014;
use warnings;
use ntheory qw(divisors is_prob_prime);
use Math::GMPz;

sub find_semiprime_repunit_k {
    my $limit_N = 200; # Max length of the repunit

    say "Searching for k = p * q ...\n";

    my $Rn = Math::GMPz->new(1);

    for my $n (2 .. $limit_N) {
        # Dynamically build R_n: 11, 111, 1111...
        $Rn = ($Rn * 10) + 1;

        # Calculate Vn = 2*R_n - 1
        my $Vn = 2 * $Rn - 1;

        # If Vn itself is prime, its only divisors are 1 and Vn.
        # This results in p = 1, which isn't prime, so we can skip it.
        next if is_prob_prime($Vn);

        # Fetch all divisors of Vn
        # Note: As n grows, integer factorization becomes the new bottleneck!
        my @divs = divisors($Vn);

        # Iterate through pairs of divisors (we only need to go up to the square root)
        my $half_idx = scalar(@divs) / 2;

        for my $i (0 .. $half_idx - 1) {
            my $A = Math::GMPz->new($divs[$i]);
            my $B = $Vn / $A;

            my $p = ($A + 1) / 2;
            my $q = ($B + 1) / 2;

            # Check if both generated numbers are prime
            if (is_prob_prime($p) && is_prob_prime($q)) {

                my $k = Math::GMPz->new($p) * $q;

                say "Found a sequence term: k = $k";
                say "  => length of repunit n = $n";
                say "  => composed of primes:";
                say "     p = $p";
                say "     q = $q\n";
            }
        }
    }
}

find_semiprime_repunit_k();
