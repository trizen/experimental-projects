#!/usr/bin/perl

# A new algorithm for generating Carmichael numbers that are also super-pseudoprimes to base 2.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::AnyNum qw(prod);

use experimental qw(signatures);

sub carmichael_superpseudoprimes ($n) {
    my $p = nth_prime($n);

    my %table;

    #say ":: Sieving...";

    my $upto = 1e6;

    foreach my $k (1 .. $upto) {
        is_smooth($k, $p-1) || next;
        my $r = (2 * $k * $p + 1);
        if (is_prime($r)) {
            my $z = znorder(2, $r);
            foreach my $d(divisors($r-1)) {
                if ($d % $z == 0) {
                    push @{$table{$d}}, $r;
                }
            }
        }
    }

    #say ":: Creating combinations...";

    foreach my $arr (values %table) {

        my $l = scalar(@$arr);
        my $k = 5;               # minimum number of prime factors

        next if ($l < $k);

        foreach my $j ($k .. $l) {
            forcomb {
                my $C = prod(@{$arr}[@_]);
                if ($C > ~0 and is_carmichael($C)) {
                    say $C;
                }
            } $l, $j;
        }
    }
}

foreach my $n(2..100) {
    say ":: Generating with n = $n and p = ", nth_prime($n);
    carmichael_superpseudoprimes($n);
}
