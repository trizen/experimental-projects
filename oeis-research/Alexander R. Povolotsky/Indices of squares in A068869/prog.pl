#!/usr/bin/perl

# Indices of squares in A068869.
# https://oeis.org/A360210

# Known terms:
#   1, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16

# Next term, if it exists, is greater than 160000.

use 5.014;
use strict;
use warnings;

use Math::GMPz;

my $t = Math::GMPz::Rmpz_init_set_ui(1);
my $z = Math::GMPz::Rmpz_init_set_ui(1);

foreach my $n (2..1e9) {

    if ($n % 1e4 == 0) {
        say "Checking: $n";
    }

    Math::GMPz::Rmpz_mul_ui($t, $t, $n);
    Math::GMPz::Rmpz_sub_ui($z, $t, 1);
    Math::GMPz::Rmpz_sqrt($z, $z);
    Math::GMPz::Rmpz_add_ui($z, $z, 1);
    Math::GMPz::Rmpz_mul($z, $z, $z);
    Math::GMPz::Rmpz_sub($z, $z, $t);

    if (Math::GMPz::Rmpz_perfect_square_p($z)) {
        say $n;
    }
}

__END__
func isok(n) {
    (n!-1 -> isqrt+1)**2 - n! -> is_square
}

for n in (0..100) {
    if (isok(n)){
        print(n, ", ")
    }
}
