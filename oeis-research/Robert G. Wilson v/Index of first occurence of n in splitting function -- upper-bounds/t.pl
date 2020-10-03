#!/usr/bin/perl

# a(n) is the smallest integer k of the form k = x*(x + a(n-1)), such that A324920(k) = n, for some positive integer x, with a(0) = 0.
# https://oeis.org/A307034

use 5.020;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

# Values of x:
#   1, 1, 1, 2, 1, 2, 3, 2, 1, 2, 5, 12, 7, 4, 9, 10, 3, 8, 43, 6, 73, 34, 5, 14, 53, 56, 9, 68, 205, 42, 109, 36, 59, 46, 83, 90, 133, 124, 9, 14, 39, 2, 109, 224, 11, 30, 91, 12,

sub f($n) {
    if (is_square($n)) {
        0;
    }
    else {

        #~ if (divisor_sum($n,0) % 2) {
            #~ return 0;
        #~ }

        my @d = divisors($n);
        Math::GMPz->new($d[(1 + $#d) >> 1]) - $d[($#d) >> 1];
    }
}

sub g($n) {

    my $t     = f($n);
    my $count = 1;

    while ($t) {
        $t = f($t);
        ++$count;
    }

    $count;
}

# x * (x + n) = x^2 + x*n + n

#my $n_str = "0";
my $n = Math::GMPz->new(0);
local $| = 1;

for my $j (1 .. 50) {

    for (my $x = 1 ; ; ++$x) {

        my $k = $x * ($n + $x);
        #my $k_str = "$x * ($x + $n_str)";
        my $t = g($k);

        if ($t == $j) {
            $n = $k;
         #   $n_str = $k_str;
            #say "a($j) = $k with x = $x";
            print "$x, ";
            #say "a($j) = ", $k_str;
            #say
            last;
        }
    }
}
