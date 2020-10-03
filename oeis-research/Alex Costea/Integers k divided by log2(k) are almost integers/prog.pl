#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 10 July 2019
# https://github.com/trizen

# Positive integers k at which k/log_2(k) is at a record closeness to an integer, without actually being an integer.
# https://oeis.org/A307099

# Known terms:
#    3, 10, 51, 189, 227, 356, 578, 677, 996, 3389, 38997, 69096, 149462, 2208495, 3459604, 4952236, 6710605, 48098656, 81762222, 419495413

# Similar sequence for k/log(k):
#   2, 5, 9, 13, 17, 163, 53453, 110673, 715533
#   https://oeis.org/A178805

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

my $prev = 1;

#use Math::AnyNum qw(round);
#use POSIX qw(log2 round);

use Math::MPFR;

my $PREC = 128;

my $mpfr = Math::MPFR::Rmpfr_init2($PREC);
my $ln2 = Math::MPFR::Rmpfr_init2($PREC);

Math::MPFR::Rmpfr_const_log2($ln2, 0);

sub log2 ($x) {
    Math::MPFR::Rmpfr_log_ui($mpfr, $x, 0);
    Math::MPFR::Rmpfr_div($mpfr, $mpfr, $ln2, 0);
    $mpfr;
}

sub round ($x) {
    Math::MPFR::Rmpfr_round($mpfr, $x);
    $mpfr;
}

sub bsearch_le ($left, $right, $callback) {

    my ($mid, $cmp);

    for (; ;) {

        $mid = int(($left + $right) / 2);
        $cmp = $callback->($mid) || return $mid;

        if ($cmp < 0) {
            $left = $mid + 1;
            $left > $right and last;
        }
        else {
            $right = $mid - 1;

            if ($left > $right) {
                $mid -= 1;
                last;
            }
        }
    }

    return $mid;
}

sub find_k($x) {

    my $k = bsearch_le($prev, 1e12, sub ($k) {
       $k/log2($k) <=> $x
    });

    my $t1 = $k/log2($k);
    my $t2 = ($k+1)/log2($k+1);

    if (abs($x - $t2) < abs($x - $t1)) {
        return ($t2, $k+1)
    }

    return ($t1, $k);
}

sub diff($x) { abs($x - round($x)) }

local $| = 1;
my $mindiff = 100000;

foreach my $x(2..1e9) {

    my ($t, $k) = find_k($x);

    if (($k&($k-1)) == 0) {
        next;
    }

    my $dx = diff($t);

    if ($dx < $mindiff) {
        $mindiff = $dx;
        print($k, ", ");
        $prev = $k;
    }
}

say "Mindiff = $mindiff";
