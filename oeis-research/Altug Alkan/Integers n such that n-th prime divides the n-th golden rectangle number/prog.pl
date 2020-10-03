#!/usr/bin/perl

# Integers n such that n-th prime divides the n-th golden rectangle number.
# https://oeis.org/A271332

# Known terms:
#    6, 15, 51, 754, 803, 2160, 3048, 8315, 18549, 27094, 89929, 251712, 505768, 936240, 1617182, 2182656, 2582372, 5116884, 27067121, 77131559

use 5.014;
use ntheory qw(:all);

local $| = 1;
my $count = 1;

forprimes {

    if (mulmod((lucas_sequence($_, 1, -1, $count))[0], (lucas_sequence($_, 1, -1, $count+1))[0], $_) == 0) {
        print($count, ", ");
    }

    ++$count;
} 1e11;
