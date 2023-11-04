#!/usr/bin/perl

# Try to find a BPSW pseudoprime for the GMP library.

# See also:
#   https://gmplib.org/manual/Number-Theoretic-Functions

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;

my $z = Math::GMPz::Rmpz_init_nobless();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;

    #next if $n > ~0;

    Math::GMPz::Rmpz_set_str($z, $n, 10);

    if (Math::GMPz::Rmpz_probab_prime_p($z, 1)) {
        die "\nCounter-example: $n\n";
    }
}

say "No counter-example found...";
