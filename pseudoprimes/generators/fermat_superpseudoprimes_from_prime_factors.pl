#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 28 January 2019
# https://github.com/trizen

# A new algorithm for generating Fermat superpseudoprimes to any given base.

# See also:
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(prod);
use ntheory qw(:all);

sub fermat_superpseudoprimes ($base, $callback) {

    my %common_divisors;

    #for (my $p = 2; $p <= $prime_limit; $p = next_prime($p)) {

    say "# :: Sieving...";

    my %seen_p;
    while (<>) {
        my $p = (split(' ', $_))[-1];
        $p || next;
        next if /^#/;
        $p =~ /^[0-9]+\z/ or next;
        $p > 2 or next;
        is_prime($p) || next;
        next if $seen_p{$p}++;

        my $z = znorder($base, $p) // next;

        $z < ~0 or next;
        #push @{$common_divisors{$z}}, $p;      # overpseudoprimes

        foreach my $d (divisors(subint($p, 1))) {
            #if ($d % $z == 0) {
            if ($d >= $z and modint($d, $z) == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    }

    say "# :: Creating combinations...";

    my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n) if !$seen{$n}++;
            } $l, $k;
        }
    }
}

my $base = 2;

fermat_superpseudoprimes(
    $base,           # base
    sub ($n) {

        Math::Prime::Util::GMP::is_pseudoprime($n, $base) || die "error for n=$n";

        if ($n > ~0) {
            say $n;
        }
    }
);
