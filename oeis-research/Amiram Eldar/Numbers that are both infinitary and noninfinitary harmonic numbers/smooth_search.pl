#!/usr/bin/perl

# Numbers that are both infinitary and noninfinitary harmonic numbers
# https://oeis.org/A348922

# Known terms:
#   45, 60, 54600, 257040, 1801800, 2789640, 4299750, 47297250, 1707259680, 4093362000

# a(7) > 10^10, if it exists. - Amiram Eldar, Nov 04 2021

# Equivalently, numbers n such that isigma(n) divides n*isigma_0(n) and nisigma(n) divides n*nisigma_0(n).

# Non-squarefree numbers n such that A049417(n) divides n*A037445(n) and A348271(n) divides n*A348341(n).

# See also:
#   https://oeis.org/A247077

# The sequence also includes:
#   18779856480
#   44425017000
#   13594055202000
#   27188110404000
#   299069214444000
#   6824215711404000

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::Sidef qw(isigma isigma0 nisigma nisigma0);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 10;
    }

    if ($p == 3) {
        return valuation($n, $p) < 12;
    }

    if ($p == 5) {
        return valuation($n, $p) < 7;
    }

    if ($p == 7) {
        return valuation($n, $p) < 7;
    }

    if ($p == 11) {
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

    (($n*isigma0($n)) % isigma($n)) == 0 or return;

    my $t = nisigma($n);
    $t == 0 and return;

    (($n*nisigma0($n)) % $t) == 0 or return;

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
    if ($n > 1e10 and isok($n)) {
    #if (isok($n)) {
        say $n;
    }
}
