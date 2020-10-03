#!/usr/bin/perl

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(prod);
use ntheory qw(:all);

sub fermat_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    forprimes {
        my $p = $_;
        foreach my $d (divisors($p - 1)) {
            if (powmod(2, $d, $p) == 1) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    } $limit;

    my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = $#{$arr} + 1;

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                $callback->($n) if !$seen{$n}++;
            } $l, $k;
        }
    }
}

my @pseudoprimes;

fermat_pseudoprimes(
    1e5,
    sub ($n) {

        my $t = "$n";

        if ($t > ~0) {
            say $t;
        }

        if ($t eq reverse($t)) {
            if ($t > 1037998220228997301) {
                die "New term: $t";
            }
            say "Palindrome: $t";
        }
    }
);
