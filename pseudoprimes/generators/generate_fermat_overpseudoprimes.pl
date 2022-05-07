#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 28 January 2019
# https://github.com/trizen

# A new algorithm for generating Fermat overpseudoprimes to any given base.

# See also:
#   https://oeis.org/A141232 -- Overpseudoprimes to base 2: composite k such that k = A137576((k-1)/2).

# See also:
#   https://en.wikipedia.org/wiki/Fermat_pseudoprime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(prod);
use ntheory qw(:all);

sub fermat_overpseudoprimes ($base, $callback) {

    my %common_divisors;

    say ":: Sieving...";

    forprimes {
        my $p = $_;
        my $z = znorder($base, $p);
        if (defined($z)) {
            if ($z < 2e8) {
                push @{$common_divisors{$z}}, $p;
            }
        }
    } 1e9,3e9;

   say ":: Done sieving...";

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                $callback->($n)
            } $l, $k;
        }
    }
}

my @pseudoprimes;

my $base = 2;            # generate overpseudoprime to this base

fermat_overpseudoprimes(
    $base,           # base
    sub ($n) {
        if ($n > ~0) {
            say $n;
        }
    }
);
