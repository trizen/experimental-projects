#!/usr/bin/perl

# Triangular numbers (A000217) whose arithmetic derivative (A003415) is also a triangular number.
# https://oeis.org/A351130

# Known terms:
#   0, 1, 3, 21, 351, 43956, 187578, 246753, 570846, 1200475, 4890628, 15671601, 83663580, 442903203, 3776109156, 35358717628, 1060996913571, 2443123072855, 65801068940503, 598914888327003, 1364298098094561

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub arithmetic_derivative ($n) {

    my $sum = 0;

    foreach my $p (factor($n)) {
        $sum = addint($sum, divint($n, $p));
    }

    return $sum;
}

#my $from = 1;
my $from = 52235966;

local $| = 1;
foreach my $n ($from .. 1e13) {

    my $t = mulint($n, $n + 1) >> 1;

    if (is_polygonal(arithmetic_derivative($t), 3)) {
        print($t, ", ");
    }
}
