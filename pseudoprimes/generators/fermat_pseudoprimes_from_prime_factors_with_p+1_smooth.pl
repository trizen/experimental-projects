#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 02 July 2022
# https://github.com/trizen

# A new algorithm for generating Fermat pseudoprimes to any given base.

# See also:
#   https://oeis.org/A001567 -- Fermat pseudoprimes to base 2, also called Sarrus numbers or Poulet numbers.
#   https://oeis.org/A050217 -- Super-Poulet numbers: Poulet numbers whose divisors d all satisfy d|2^d-2.

# See also:
#   https://en.wikipedia.org/wiki/Fermat_pseudoprime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.020;
use warnings;
use experimental qw(signatures);

#use Math::AnyNum qw(prod);
use Math::Prime::Util::GMP qw();
use ntheory      qw(:all);

sub fermat_pseudoprimes ($base, $k_limit, $callback) {

    my %common_divisors;

    while (<>) {
        next if /^#/;
        chomp(my $p = (split(' '))[-1]);
        my $z = znorder($base, $p) // next;
        for my $k (1 .. $k_limit) {
            my $q = mulint($k, $z) + 1;
            if (kronecker(5,$q) == -1 and is_prime($q) and is_smooth($q+1, 1000)) {
                push @{$common_divisors{$z}}, $q;
            }
        }
    }

    #my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);

        foreach my $k (2 .. $l) {
            ($k % 2 == 1) or next;
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n) #if #!$seen{$n}++;
            } $l, $k;
        }
    }
}

my $base        = 2;        # generate Fermat pseudoprimes to this base
my $k_limit     = 500;      # largest k multiple of the znorder(base, p)

fermat_pseudoprimes(
    $base,                 # base
    $k_limit,              # k limit
    sub ($n) {
        if (Math::Prime::Util::GMP::is_pseudoprime($n, $base)) {
           say $n;
        }
    }
);
