#!/usr/bin/perl

# Least number k such that both prime(k+1) -/+ prime(k) are products of n prime factors (counting multiplicity).
# https://oeis.org/A288507

use 5.014;
use ntheory qw(factor prime_count forprimes next_prime nth_prime    );

#my $k = 1;

my $k = 73268943890-100;
my $p = nth_prime($k);
my $n = 9;

forprimes {

    my $q = $_;

    if (scalar(factor($p+$q)) == $n and $n == scalar(factor($q-$p))) {
        say "Found: ", prime_count($p), " with ", $p+$q, " and ", $q-$p, " with p = $p";
        ++$n;
    }

    $p = $_;
    #++$k;
} next_prime($p), 1e13
