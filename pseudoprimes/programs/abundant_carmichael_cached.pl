#!/usr/bin/perl

# a(n) = smallest pseudoprime to base 2 with n prime factors.
# https://oeis.org/A007011

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use POSIX        qw(ULONG_MAX);

my $storable_file = "cache/factors-carmichael.storable";
my $carmichael    = retrieve($storable_file);

sub my_sigma ($factors) {    # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_mul_ui($t, $t, $p + 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, $p, 10);
            Math::GMPz::Rmpz_add_ui($u, $u, 1);
            Math::GMPz::Rmpz_mul($t, $t, $u);
        }
    }

    return $t;
}

my $t = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %$carmichael) {

    Math::Prime::Util::GMP::modint($key, 5) == 0
      or Math::Prime::Util::GMP::modint($key, 3) == 0
      or next;

    my @factors = split(' ', $value);

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    Math::GMPz::Rmpz_mul_2exp($t, $t, 1);

    if (my_sigma(\@factors) >= $t) {
        say $key;
    }
}
