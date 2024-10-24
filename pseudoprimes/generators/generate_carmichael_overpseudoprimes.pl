#!/usr/bin/perl

# A new algorithm for generating Carmichael numbers that are also overpseudoprimes to base 2.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::AnyNum qw(prod);

use experimental qw(signatures);

sub carmichael_overpseudoprimes ($n) {
    my $p = nth_prime($n);

    my %table;

    #say ":: Sieving...";

    my $upto = 1e6;

    foreach my $k (1 .. $upto) {
        is_smooth($k, $p-1) || next;
        my $r = (4 * $k * $p + 1);
        if (is_prime($r)) {
            push @{$table{znorder(2, $r)}}, $r;
        }
    }

    #say ":: Creating combinations...";

    foreach my $arr (values %table) {

        my $l = scalar(@$arr);
        my $k = 4;               # minimum number of prime factors

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

foreach my $n (prime_count(919) .. 3000) {
    say ":: Generating with n = $n and p = ", nth_prime($n);
    carmichael_overpseudoprimes($n);
}
