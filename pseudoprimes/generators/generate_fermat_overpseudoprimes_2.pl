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

sub fermat_overpseudoprimes ($base, $prime_limit, $callback) {

    my %common_divisors;

    say ":: Sieving...";

    forprimes {
        my $p = $_;
        my $z = znorder($base, $p);
        if ($p < 3e8 or exists($common_divisors{$z})) {
            push @{$common_divisors{$z}}, $p;
        }
    } 3, $prime_limit;

   say ":: Done sieving...";

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);

        foreach my $k (4 .. $l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                $callback->($n);
            } $l, $k;
        }
    }
}

sub is_fibonacci_pseudoprime ($n) {
    (lucas_sequence($n, 1, -1, $n - kronecker($n, 5)))[0] == 0;
}

my $base        = 2;            # generate overpseudoprime to this base
my $prime_limit = 1e10;       # sieve primes up to this limit

open my $fh, '>', 'file7.txt';

fermat_overpseudoprimes(
    $base,           # base
    $prime_limit,    # prime limit
    sub ($n) {

            say $n;
            say $fh $n;

    }
);

