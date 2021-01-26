#!/usr/bin/perl

# Numbers k such that prime(k)^prime(k+1) == prime(k+2) (mod prime(k+3)).
# https://oeis.org/A340876

# Known terms:
#   942, 4658911, 12806325

# New terms:
#   2515276754

use 5.014;
use ntheory qw(:all);

my ($p, $q, $r, $s) = (1, 2, 3, 5, 7);

local $| = 1;

forprimes {

    if (powmod($p, $q, $s) == $r) {
        print(prime_count($p), ", ");
    }

   ($p, $q, $r, $s) =  ($q, $r, $s, $_);

} next_prime($s), 1e12;
