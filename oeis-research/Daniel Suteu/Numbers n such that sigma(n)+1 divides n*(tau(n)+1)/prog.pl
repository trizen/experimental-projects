#!/usr/bin/perl

# Number k such that sigma(k)+1 divides k*(tau(k)+1).

# The first several terms:
#   1, 4, 15, 16, 64, 245, 256, 1014, 1024, 4096, 16384, 46875, 65536, 262144, 1048576, 4084223, 4194304, 16777216

# The first terms in the sequence that are not powers of 2:
#   15, 245, 1014, 46875, 4084223

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);

sub isok($n) {
    modint(mulint($n, divisor_sum($n, 0)+1), divisor_sum($n)+1) == 0;
}

local $| = 1;

foreach my $k(1..1e9) {
    if (isok($k)) {
        print($k, ", ");
    }
}
