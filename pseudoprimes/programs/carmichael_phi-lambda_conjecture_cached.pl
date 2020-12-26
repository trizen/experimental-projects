#!/usr/bin/perl

# Numbers n such that (n-1) mod phi(n) = lambda(n), where phi = A000010 and lambda = A002322.
# https://oeis.org/A290281

# Conjecture: these are numbers n such that phi(n) + lambda(n) = n - 1. Checked up to 2^64. - Amiram Eldar and Thomas Ordowski, Dec 06 2019

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $table         = retrieve($storable_file);

sub my_euler_phi ($factors) {    # assumes n is squarefree
    Math::Prime::Util::GMP::vecprod(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);
}

sub my_carmichael_lambda ($factors) {    # assumes n is squarefree
    Math::Prime::Util::GMP::lcm(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);
}

my @results;

my $u = Math::GMPz::Rmpz_init();
my $v = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %$table) {

    my @factors = split(' ', $value);

    Math::GMPz::Rmpz_set_str($u, $key, 10);
    Math::GMPz::Rmpz_sub_ui($u, $u, 1);

    my $phi    = my_euler_phi(\@factors);
    my $lambda = my_carmichael_lambda(\@factors);

    Math::GMPz::Rmpz_set_str($v, $phi, 10);
    Math::GMPz::Rmpz_mod($u, $u, $v);

    Math::GMPz::Rmpz_set_str($v, $lambda, 10);

    if (Math::GMPz::Rmpz_cmp($u, $v) == 0) {
        say "Found: $key";
    }
}

__END__

# No known terms > 2^64.
