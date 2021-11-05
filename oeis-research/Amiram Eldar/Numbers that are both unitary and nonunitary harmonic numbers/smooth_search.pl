#!/usr/bin/perl

# Numbers that are both unitary and nonunitary harmonic numbers.
# https://oeis.org/A348923

# Known terms:
#   45, 60, 3780, 64260, 3112200, 6320160

# a(7) > 10^12, if it exists. - Amiram Eldar, Nov 04 2021

# Equivalently, numbers n such that usigma(n) divides n*usigma_0(n) and sigma(n) - usigma(n) divides n*(sigma_0(n) - usigma_0(n)).

# Non-squarefree numbers n such that A034448(n) divides n*A034444(n) and A048146(n) divides n*A048105(n).

# See also:
#   https://oeis.org/A247077

# No other terms are known...

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 20;
    }

    if ($p == 3) {
        return valuation($n, $p) < 5;
    }

    if ($p == 5) {
        return valuation($n, $p) < 4;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    ($n % $p) != 0;
    #valuation($n, $p) < 2;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub usigma($n) {
    vecprod(map { addint(powint($_->[0], $_->[1]), 1) } factor_exp($n));
}

sub isok ($n) {

    is_square_free($n) && return;

    my $usigma = usigma($n);
    my $usigma0 = powint(2, prime_omega($n));

    modint(mulint($n, $usigma0), $usigma) == 0 or return;

    my $t = subint(divisor_sum($n), $usigma);
    $t == 0 and return;

    modint(mulint($n, subint(divisor_sum($n, 0), $usigma0)), $t) == 0 or return;

    return 1;
}

my @smooth_primes;

foreach my $p (@{primes(4801)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (
        is_smooth($p-1, 5) and
        is_smooth($p+1, 7)
    ) {
        push @smooth_primes, $p;
    }
}

my $h = smooth_numbers(~0, \@smooth_primes);

say "\nGenerated: ", scalar(@$h), " numbers";

foreach my $n (@$h) {
    if ($n > 1e12 and isok($n)) {
    #if (isok($n)) {
        say $n;
    }
}
