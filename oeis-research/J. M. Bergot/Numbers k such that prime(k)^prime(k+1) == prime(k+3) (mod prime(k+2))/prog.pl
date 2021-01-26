#!/usr/bin/perl

# Numbers k such that prime(k)^prime(k+1) == prime(k+3) (mod prime(k+2)).
# https://oeis.org/A340868

# Known terms:
#   15, 52, 701, 26017, 579994, 1131833

use 5.014;
use ntheory qw(:all);

my ($p, $q, $r, $s) = (1, 2, 3, 5, 7);

local $| = 1;

forprimes {

    if (powmod($p, $q, $r) == ($s % $r)) {
        print(prime_count($p), ", ");
    }

   ($p, $q, $r, $s) =  ($q, $r, $s, $_);

} next_prime($s), 1e12;
