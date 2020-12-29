#!/usr/bin/perl

# Composite numbers n such that phi(n) divides p*(n - 1) for some prime factor p of n-1.
# https://oeis.org/A338998

# Known terms:
#   1729, 12801, 5079361, 34479361, 3069196417

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use Math::Sidef qw(trial_factor);
use List::Util qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael      = retrieve($carmichael_file);

sub my_euler_phi ($factors) {    # assumes n is squarefree
    Math::Prime::Util::GMP::vecprod(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);
}

sub is_smooth_over_prod ($n, $k) {

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_set($t, $n);
    Math::GMPz::Rmpz_gcd($g, $t, $k);

    while (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_remove($t, $t, $g);
        return 1 if Math::GMPz::Rmpz_cmp_ui($t, 1) == 0;
        Math::GMPz::Rmpz_gcd($g, $t, $g);
    }

    return 0;
}

my $t   = Math::GMPz::Rmpz_init();
my $nm1 = Math::GMPz::Rmpz_init();
my $phi = Math::GMPz::Rmpz_init();

my $primorial = Math::GMPz::Rmpz_init();
Math::GMPz::Rmpz_primorial_ui($primorial, 1e6);

while (my ($key, $value) = each %$carmichael) {

    length($key) <= 30 or next;

    Math::GMPz::Rmpz_set_str($nm1, $key, 10);
    Math::GMPz::Rmpz_sub_ui($nm1, $nm1, 1);

    is_smooth_over_prod($nm1, $primorial) || next;

    my @factors = split(' ', $value);
    Math::GMPz::Rmpz_set_str($phi, my_euler_phi(\@factors), 10);

    my @nm1_factors = uniq(Math::Prime::Util::GMP::factor($nm1));

    if (
        vecany {
            Math::GMPz::Rmpz_mul_ui($t, $nm1, $_);
            Math::GMPz::Rmpz_divisible_p($t, $phi);
        }
        @nm1_factors
      ) {
        say $key;
    }
}

__END__

# No terms > 2^64 are known.
