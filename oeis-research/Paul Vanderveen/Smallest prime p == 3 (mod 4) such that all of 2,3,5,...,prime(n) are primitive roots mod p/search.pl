#!/usr/bin/perl

# Smallest prime p == 3 (mod 4) such that all of 2,3,5,...,prime(n) are primitive roots mod p.
# https://oeis.org/A350121

# Known terms:
#   3, 19, 907, 1747, 2083, 101467, 350443, 916507, 1014787, 6603283, 27068563, 45287587, 226432243, 243060283, 3946895803, 5571195667, 9259384843, 19633449763

# Based on code by Dana Jacobsen (Jul 11 2018) from https://oeis.org/A213052

use 5.020;
use warnings;

use Math::Prime::Util ":all";

my ($N, $A, $p, $a, @P7) = (10**13, 2);

forprimes {

    $p = $_;

    if (    $p % 4 == 3
        and is_primitive_root(2, $p)
        and ($A < 3 || is_primitive_root(3, $p))
        and ($A < 5 || is_primitive_root(5, $p))
        and ($A < 7 || vecall { is_primitive_root($_, $p) } @P7)
    ) {
        say $p;
        $A = next_prime($A);
        push(@P7, $A) if ($A >= 7);
    }

} 3, $N;
