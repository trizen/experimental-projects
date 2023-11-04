#!/usr/bin/perl

# Squarefree composite numbers m such that rad(p-1) = rad(m-1) for every prime p dividing m.
# https://oeis.org/A306479

# First few terms:
#   1729, 46657, 1525781251

# Additional terms (with possible gaps):
#   763546828801, 6031047559681, 184597450297471, 732785991945841, 18641350656000001, 55212580317094201

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use POSIX qw(ULONG_MAX);

use Math::GMPz;
use Math::GMPq;
use Math::MPFR;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util   qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael      = retrieve($carmichael_file);

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

my $pm1 = Math::GMPz::Rmpz_init();
my $nm1 = Math::GMPz::Rmpz_init();

my @results;

while (my ($key, $value) = each %$carmichael) {

    my @factors = split(' ', $value);

    Math::GMPz::Rmpz_set_str($nm1, $key, 10);
    Math::GMPz::Rmpz_sub_ui($nm1, $nm1, 1);

    if (
        vecall {

            Math::GMPz::Rmpz_set_str($pm1, $_, 10);
            Math::GMPz::Rmpz_sub_ui($pm1, $pm1, 1);

            is_smooth_over_prod($nm1, $pm1);
        }
        @factors
      ) {
        say $key;
    }
}

__END__

# No Carmichael terms > 2^64 are known.
