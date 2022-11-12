#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 02 July 2022
# Edit: 12 November 2022
# https://github.com/trizen

# A new algorithm for generating Fermat pseudoprimes to multiple bases.

# See also:
#   https://oeis.org/A001567 -- Fermat pseudoprimes to base 2, also called Sarrus numbers or Poulet numbers.
#   https://oeis.org/A050217 -- Super-Poulet numbers: Poulet numbers whose divisors d all satisfy d|2^d-2.

# See also:
#   https://en.wikipedia.org/wiki/Fermat_pseudoprime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.020;
use warnings;
use experimental qw(signatures);

use ntheory qw(:all);
use Math::Prime::Util::GMP qw(vecprod is_pseudoprime);
use Math::GMPz;
use List::Util qw(uniq);

sub fermat_pseudoprimes ($bases, $k_limit,  $callback) {

    my %common_divisors;
    my $bases_lcm = lcm(@$bases);

  #  for (my $p = 2 ; $p <= $prime_limit ; $p = next_prime($p)) {


    my %seen_p;
    while (<>) {
        my $p = (split(' ', $_))[-1];
 #   foreach my $p(@plist) {

        $p || next;
        $p =~ /^[0-9]+\z/ or next;
        is_prime($p) || next;
        next if $seen_p{$p}++;

        if ($p > ~0) {
            $p = Math::GMPz->new($p);
        }

        next if ($bases_lcm % $p == 0);

        my @orders     = map { znorder($_, $p) } @$bases;
        my $lcm_orders = lcm(@orders);

        for my $k (1 .. $k_limit) {
            my $q = mulint($k, $lcm_orders) + 1;
            if ($p != $q and is_prime($q)) {
                push @{$common_divisors{$lcm_orders}}, $q;
            }
        }
    }

    #my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);

        @$arr = uniq(@$arr);

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = vecprod(@{$arr}[@_]);
                $callback->($n) #if !$seen{$n}++;
            } $l, $k;
        }
    }
}

my @pseudoprimes;

my @bases       = @{primes(nth_prime(10))};    # generate Fermat pseudoprimes to these bases
my $k_limit     = 24;        # largest k multiple of the znorder(base, p)

fermat_pseudoprimes(
    \@bases,                 # bases
    $k_limit,                # k limit
    sub ($n) {
        if ($n > ~0 and is_pseudoprime($n, @bases)) {
           # push @pseudoprimes, $n;
           say $n;
        }
    }
);
