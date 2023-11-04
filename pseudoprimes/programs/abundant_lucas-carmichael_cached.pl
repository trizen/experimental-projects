#!/usr/bin/perl

# a(n) = smallest pseudoprime to base 2 with n prime factors.
# https://oeis.org/A007011

# An example for a Lucas-Carmichael number that is also an abundant number:
#   1012591408428327888883952080728349448745451794025524955777432246705535

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use POSIX        qw(ULONG_MAX);
use Math::MPFR;

my $storable_file    = "cache/factors-lucas-carmichael.storable";
my $lucas_carmichael = retrieve($storable_file);

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

while (my ($key, $value) = each %$lucas_carmichael) {

         Math::Prime::Util::GMP::modint($key, 5) == 0
      or Math::Prime::Util::GMP::modint($key, 3) == 0
      or Math::Prime::Util::GMP::modint($key, 7) == 0
      or next;

    my @factors = split(' ', $value);

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    my $abundancy = Math::MPFR->new(my_sigma(\@factors)) / $t;

    #~ if ($abundancy >= 1.9) {
    #~ my $s = sprintf("%.3f", $abundancy);
    #~ if ($s == 2 and $abundancy < 2) {
    #~ $s = "1.999";
    #~ }
    #~ printf("%s %s\n", $s, $key);
    #~ }

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    Math::GMPz::Rmpz_mul_2exp($t, $t, 1);

    if (my_sigma(\@factors) >= $t) {
        say $key;
    }
}
