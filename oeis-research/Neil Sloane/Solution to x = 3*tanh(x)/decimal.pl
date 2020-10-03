#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 30 July 2019
# https://github.com/trizen

# Compute a solution to x = 3*tanh(x), starting as x = 2.9847045853578868155597912346...

# https://oeis.org/A309211      -- decimal
# https://oeis.org/A309207      -- cfrac

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use Math::AnyNum qw(:overload approx_cmp float tanh);

local $Math::AnyNum::PREC = 50000;

sub binary_inverse ($n, $f, $min = 0, $max = $n) {

    ($min, $max) = ($max, $min) if ($min > $max);

    $min = float($min);
    $max = float($max);

    for (; ;) {
        my $m = ($min + $max) / 2;
        my ($x, $y) = $f->($m);
        my $c = approx_cmp($x, $y);

        if ($c < 0) {
            $min = $m;
        }
        elsif ($c > 0) {
            $max = $m;
        }
        else {
            return "$m";
        }
    }
}

my $x = binary_inverse(4, sub ($x) { ($x,  3*tanh($x)) }, 1, 4);

say $x;
say 3*tanh($x);
