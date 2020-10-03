#!/usr/bin/perl

# Numbers k such that (prime(k)+composite(k))/k is an integer, where prime(k) is the k-th prime.
# https://oeis.org/A329112

# Known terms:
#   1, 4, 346, 365, 891, 5668, 5677, 588138, 588142, 588144, 9872786, 9872948, 170160524, 441666155, 441666208

# PARI/GP program:
#   upto(n) = my(p=2, k=1); forcomposite(c=4, n, if((p+c)%k == 0, print1(k, ", ")); p=nextprime(p+1); k++);

use 5.014;
use ntheory qw(:all);

my $p = 2;
my $k = 1;

local $| = 1;

forcomposites {

    if (($p + $_) % $k == 0) {
        print($k, ", ");
    }

    ++$k;
    $p = next_prime($p);
} 1e9;
