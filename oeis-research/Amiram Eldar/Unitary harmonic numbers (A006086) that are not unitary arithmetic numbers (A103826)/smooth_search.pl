#!/usr/bin/perl

# Unitary harmonic numbers (A006086) that are not unitary arithmetic numbers (A103826).
# https://oeis.org/A353038

# Known terms:
#   90, 40682250, 81364500, 105773850, 423095400, 1798155450, 14385243600

# No other terms are known.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 7;
    }

    if ($p == 3) {
        return valuation($n, $p) < 7;
    }

    if ($p == 5) {
        return valuation($n, $p) < 6;
    }

    if ($p == 7) {
        return valuation($n, $p) < 5;
    }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 2;
    #~ }

    if ($p == 13) {
        return valuation($n, $p) < 2;
    }

    if ($p == 17) {
        return valuation($n, $p) < 2;
    }

    if ($p == 41) {
        return valuation($n, $p) < 2;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
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

#use Math::Sidef qw(usigma usigma0);

sub isok ($n) {
    #is_power(Math::GMPz->new(divisor_sum($n)) * euler_phi($n));
    # is(n)=my(f=factor(n)); prod(i=1, #f~, f[i, 1]^f[i, 2]+1)%2^#f~==0

    my @f = factor_exp($n);

    my $usigma = vecprod(map { powint($_->[0], $_->[1]) + 1 } @f);
    my $usigma0 = powint(2, scalar(@f));

    modint($usigma, $usigma0) == 0
        and return;

    modint(mulint($n, $usigma0), $usigma) == 0;

    #(usigma0($n)*$n) % usigma($n) == 0;
}

my @smooth_primes;

foreach my $p (@{primes(5000)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    if ($f1[-1] <= 5 and $f2[-1] <= 7) {
        push @smooth_primes, $p;
    }
}

my $h = smooth_numbers(Math::GMPz->new(10)**30, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    $n > 1e12 or next;
    $n % 2 == 0 or next;

    if (isok($n)) {
        say $n;
    }
}
