#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Generalized algorithm for generating numbers that are smooth over a set A of primes, bellow a given limit.

#~ 2915
#~ 5183999999
#~ 574806585599

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 5;
    }

    if ($p == 3) {
        return valuation($n, $p) < 3;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit) { #and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

#
# Example for finding numbers `m` such that:
#     sigma(m) * phi(m) = n^k
# for some `n` and `k`, with `n > 1` and `k > 1`.
#
# See also: https://oeis.org/A306724
#

sub rad ($n) {
    vecprod(map { $_->[0] } factor_exp($n));
}

sub isok ($k) {
    my $n = $k-1;
    my $t = rad($n+1);
    vecall { rad($_+1) == $t } factor($n);
}

my $h = smooth_numbers(10**12, primes(30));

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    if (!is_prime($n-1) and isok($n) and is_square_free($n-1) ) {
        say $n-1;
    }

    #~ my $p = isok($n);

    #~ if ($p >= 8) {
        #~ say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        #~ push @{$table{$p}}, $n;
    #~ }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
