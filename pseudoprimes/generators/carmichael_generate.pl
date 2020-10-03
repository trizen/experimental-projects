#!/usr/bin/perl

# Generate Carmichael numbers.

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(prod);
use ntheory qw(:all);
use List::Util qw(uniq);
use Math::Prime::Util::GMP qw(is_pseudoprime vecprod is_carmichael);

sub fermat_pseudoprimes ($limit) {

    my %common_divisors;

    warn "Sieving...\n";

    forprimes {
        my $p = $_;

        my $z1 = znorder(2, $p);
        my $z2 = ($p == 3) ? (3-1) : znorder(3, $p);
        my $z3 = ($p == 5) ? (5-1) : znorder(5, $p);
        my $z4 = ($p == 7) ? (7-1) : znorder(7, $p);

        foreach my $d (divisors($p - 1)) {
            if (
                    gcd($d, $z1) == $z1
                #and gcd($d, $z2) == $z2
                #and gcd($d, $z3) == $z3
                and gcd($d, $z4) == $z4
            ) {
                foreach my $k (1..50) {
                    push @{$common_divisors{$d*$k}}, $p;
                }
            }
        }
    } 3, $limit;

    warn "Combinations...\n";

    foreach my $arr (values %common_divisors) {

        @$arr = uniq(@$arr);
        my $l = $#{$arr} + 1;

        foreach my $k (3 .. $l) {
            forcomb {
                my $n = vecprod(@{$arr}[@_]);

                if ($n > ~0 and is_carmichael($n)) {
                    warn "$n\n";
                    say $n;
                }
            } $l, $k;
        }
    }
}

fermat_pseudoprimes(1e5);
