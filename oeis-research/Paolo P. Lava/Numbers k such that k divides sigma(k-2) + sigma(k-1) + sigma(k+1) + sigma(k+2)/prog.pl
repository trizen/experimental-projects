#!/usr/bin/perl

# Numbers k such that k | (sigma(k-2)+sigma(k-1)+sigma(k+1)+sigma(k+2)).
# https://oeis.org/A296027

# Known terms:
#   6, 57, 443, 1407, 1410, 12242, 15051, 30952, 44277, 65190, 68697, 609531, 921774, 951092, 2012670, 2820460, 11961680, 32886944

# No other terms up to 10^9. - Michel Marcus, Sep 10 2019

# New term found:
#   3450005970

use 5.014;
use ntheory qw(:all);

local $| = 1;

my $from  = 1;
my @sigma = map { divisor_sum($_) } $from .. $from + 4;

foreach my $n ($from + 5 .. 1e10) {

    if (($sigma[0] + $sigma[1] + $sigma[3] + $sigma[4]) % ($n - 3) == 0) {
        print($n- 3, ", ");
    }

    shift @sigma;
    push @sigma, divisor_sum($n);
}
