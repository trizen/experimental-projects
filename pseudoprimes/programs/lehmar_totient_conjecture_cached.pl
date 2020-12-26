#!/usr/bin/perl

# https://oeis.org/A306828
# https://en.wikipedia.org/wiki/Lehmer%27s_totient_problem

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael      = retrieve($carmichael_file);

sub odd_part ($n) {
    $n >> valuation($n, 2);
}

sub my_euler_phi ($factors) {    # assumes n is squarefree
    Math::GMPz->new(Math::Prime::Util::GMP::vecprod(map { Math::Prime::Util::GMP::subint($_, 1) } @$factors));
}

while (my ($key, $value) = each %$carmichael) {

    # In 1980 Cohen and Hagis proved that, for any
    # solution n to the problem, n > 10^20 and ω(n) ≥ 14.

    next if (length($key) <= 20);

    my @factors = split(' ', $value);

    scalar(@factors) >= 14 or next;

    my $n = Math::GMPz->new($key);

    #say "Checking: $n";

    my $phi = my_euler_phi(\@factors);
    my $nm1 = $n - 1;

    if (odd_part($nm1) == odd_part($phi)) {
        die "[1] Counter-example: $n";
    }

    if (Math::GMPz::Rmpz_divisible_p($nm1, $phi)) {
        die "[2] Counter-example: $n";
    }
}

say "No counter-example found...";
