#!/usr/bin/perl

# a(n) is the smallest prime p such that Omega(p^n - 2) = Omega(p^n) = Omega(p^n + 2) where Omega = A001222.
# https://oeis.org/A328445

# Known terms:
#   5, 11, 127, 401, 1487, 1153, 6199, 10301, 22193, 72277

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

sub a($n) {

    for (my $p = 2 ; ; $p = next_prime($p)) {

        my $k = Math::GMPz->new($p)**$n;

        my @f1 = factor($k + 2);
        scalar(@f1) == $n or next;

        my @f2 = factor($k - 2);
        scalar(@f2) == $n or next;

        return $p;
    }
}

foreach my $n (1 .. 10) {
    say "a($n) = ", a($n);
}
