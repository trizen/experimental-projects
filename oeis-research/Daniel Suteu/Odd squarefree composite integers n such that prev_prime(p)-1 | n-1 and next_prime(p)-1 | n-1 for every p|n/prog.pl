#!/usr/bin/perl

use 5.014;
use ntheory qw(:all);

# Odd squarefree composite integers n such that prev_prime(p)-1 | n-1 and next_prime(p)-1 | n-1 for every p|n.
# 21, 253, 481, 5797, 7021, 29233, 36424081,

# Odd squarefree composite integers n such that prev_prime(p)+1 | n+1 and next_prime(p)+1 | n+1 for every p|n.
# 55, 352079, 2968199, 47393279,

local $| = 1;

foroddcomposites {
    my $n = $_;

    if (is_square_free($n) and vecall {
            ($n+1) % (next_prime($_)+1) == 0
        and ($n+1) % (prev_prime($_)+1) == 0
    } factor($_)) {
        print($_, ", ");
    }

} 1e9;
