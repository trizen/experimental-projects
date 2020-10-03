#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 07 October 2018
# https://github.com/trizen

# A simple algorithm for generating a subset of strong-Lucas pseudoprimes.

# See also:
#   https://oeis.org/A217120 -- Lucas pseudoprimes
#   https://oeis.org/A217255 -- Strong Lucas pseudoprimes
#   https://oeis.org/A177745 -- Semiprimes n such that n divides Fibonacci(n+1).
#   https://oeis.org/A212423 -- Frobenius pseudoprimes == 2,3 (mod 5) with respect to Fibonacci polynomial x^2 - x - 1.

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(forcomb forprimes is_strong_lucas_pseudoprime random_prime);
use Math::Prime::Util::GMP qw(vecprod powmod divisors kronecker lucas_sequence);
use List::Util qw(uniq);

sub fibonacci_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    #~ my $r = random_prime(1e8);
    #~ my $r2 = random_prime(1e9);

    #~ die 'error' if $r <= 1e7;
    #~ die 'error' if $r2+1e7 <= $r;

    while (<>) {
        my $p = (split(' ', $_))[-1] || next;

        $p = Math::GMPz->new($p);
        #Math::GMPz::Rmpz_kronecker_ui($p, 5) == -1 or next;

        say "Processing $p...";

        my $p_str = "$p";

        foreach my $d (divisors($p - Math::GMPz::Rmpz_kronecker_ui($p, 5))) {
            if ((lucas_sequence($p_str, 1, -1, $d))[0] == 0) {
                push @{$common_divisors{$d}}, $p_str;
                last;
            }
        }
    }

    #~ forprimes {
        #~ my $p = $_;
        #~ foreach my $d (divisors($p - kronecker($p, 5))) {
            #~ if ((lucas_sequence($p, 1, -1, $d))[0] == 0) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ } 1e7;

    #~ forprimes {
        #~ my $p = $_;
        #~ foreach my $d (divisors($p - kronecker($p, 5))) {
            #~ if ((lucas_sequence($p, 1, -1, $d))[0] == 0) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ } $r, $r+1e7;

    #~ forprimes {
        #~ my $p = $_;
        #~ foreach my $d (divisors($p - kronecker($p, 5))) {
            #~ if ((lucas_sequence($p, 1, -1, $d))[0] == 0) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ } $r2, $r2+1e7;

    my %seen;

    foreach my $arr (values %common_divisors) {

        #@$arr = uniq(@$arr);
        my $l = $#{$arr} + 1;

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = Math::GMPz->new(vecprod(@{$arr}[@_]));
                $callback->($n, @{$arr}[@_]) if !$seen{$n}++;
            } $l, $k;
        }
    }
}

sub PSW_primality_test ($n) {

    # Find P such that kronecker(n, P^2 + 4) = -1.
    my $P;
    for (my $k = 1 ; ; ++$k) {
        if (kronecker($n, $k * $k + 4) == -1) {
            $P = $k;
            last;
        }
    }

    # If LucasU(P, -1, n+1) = 0 (mod n), then n is probably prime.
    (lucas_sequence($n, $P, -1, $n + 1))[0] == 0;
}

fibonacci_pseudoprimes(
    10_000,
    sub ($n, @f) {

        if (is_strong_lucas_pseudoprime($n)) {

            say "Lucas pseudoprime: $n";

            if (powmod(2, $n-1, $n) == 1) {
                die "Found a BPSW counter-example: $n = prod(@f)";
            }
        }

        if (powmod(2, $n-1, $n) == 1) {

            say "Fermat pseudoprime: $n";

            if (PSW_primality_test($n)) {
                die "PSW counter-example: $n = prod(@f)";
            }

            if (kronecker($n, 5) == -1) {
                die "Found a Fibonacci special number: $n = prod(@f)";
            }
        }

        #~ if (kronecker($n, 5) == -1) {
            #~ if (powmod(2, $n-1, $n) == 1) {
                #~ die "Found a Fibonacci special number: $n = prod(@f)";
            #~ }
        #~ }
    }
);
