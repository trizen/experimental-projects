#!/usr/bin/perl

# Daniel "Trizen" Șuteu and M. F. Hasler
# Date: 20 April 2018
# https://github.com/trizen

# Indices of primes in tribonacci sequence A000073.
# https://oeis.org/A303263

# See also:
#   https://oeis.org/A302990

# a(12) > 291472.

use 5.020;
use strict;
use warnings;

use Math::GMPz;

my $ONE = Math::GMPz->new(1);

use ntheory qw(is_prob_prime);
use experimental qw(signatures);

sub kth_order_fibonacci ($k, $n = 2) {

    # Algorithm after M. F. Hasler from https://oeis.org/A302990
    my @a = map { $_ < $n ? ($ONE << $_) : $ONE } 1 .. ($n + 1);

    for (my $i = 2 * ($n += 1) - 2 ; $i <= $k ; ++$i) {
        $a[$i % $n] = ($a[($i - 1) % $n] << 1) - $a[$i % $n];
    }

    return @a;
}

sub find_kth_order_fibonacci_odd_prime ($k, $r = 0) {

    my $t = $k + 1;

    for (my $n = $r * $t ; ; $n += $t) {

        say "Testing: $n";

        my @a = kth_order_fibonacci($n, $k);

        if (is_prob_prime($a[-2])) {
            # say("[second] Found: $n -> ", $k + $n - 1, ' -> ', $n - 2);
            die "Found: ", $n - 2, "\n";
        }

        if (is_prob_prime($a[-1])) {
            # say("[first] Found: $n -> ", $k + $n - 1, ' -> ', $n - 1);
            die "Found: ", $n - 1, "\n";
        }
    }
}

say find_kth_order_fibonacci_odd_prime(3, int(291472/4));
