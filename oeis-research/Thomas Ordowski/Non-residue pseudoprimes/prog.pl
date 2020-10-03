#!/usr/bin/perl



# https://oeis.org/draft/A307809

use 5.014;
use strict;
use ntheory qw(:all);

# 3277, 703, 7813, 325, 2047, 85, 91, 343, 1271, 15, 931

my $n = 2;
my $q = nth_prime($n);

foroddcomposites {

    if (powmod($q, ($_-1)>>1, $_) == $_-1 and powmod($q, $_-1, $_) == 1) {
        say "a($n) = $_";
        exit;
    }

} 1e10;

# 3281,
