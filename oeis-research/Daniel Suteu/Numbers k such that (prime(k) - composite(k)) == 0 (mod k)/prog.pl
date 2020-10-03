#!/usr/bin/perl

# Numbers k such that (prime(k) - composite(k))/k is an integer, where prime(k) is the k-th prime.
# https://oeis.org/A??????

# Known terms:
#   1, 3, 11, 43, 110283, 110316, 110356, 110374, 690076, 690084, 690374, 4427209, 11267500, 491071564,

# PARI/GP program:
#   upto(n) = my(p=2, k=1); forcomposite(c=4, n, if((p-c)%k == 0, print1(k, ", ")); p=nextprime(p+1); k++);

use 5.014;
use integer;
use ntheory qw(:all);

my $k = 1;
my $p = nth_prime($k);

local $| = 1;

forcomposites {

    if (($p - $_) % $k == 0) {
        print($k, ", ");
    }

    ++$k;
    $p = next_prime($p);
} 1e9;
