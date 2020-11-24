#!/usr/bin/perl

# Primes p such that the sum of squares of primes < p is divisible by p.
# https://oeis.org/A338818

# Known terms:
#   2, 13, 59, 118259, 182603

# The next term, if it exists, is greater than 2^32.

use 5.014;
#use Primesieve;
use ntheory qw(forprimes);
use Math::Prime::Util::GMP qw(:all);

use Math::GMPz;

my $t = Math::GMPz::Rmpz_init_set_ui(0);
my $sum = Math::GMPz::Rmpz_init_set_ui(0);

forprimes {

    if (Math::GMPz::Rmpz_divisible_ui_p($sum, $_)) {
        say $_;
    }

    if ($_ < sqrt(~0)) {
        Math::GMPz::Rmpz_add_ui($sum, $sum, $_*$_);
    }
    else {
        Math::GMPz::Rmpz_set_ui($t, $_);
        Math::GMPz::Rmpz_mul($t, $t, $t);
        Math::GMPz::Rmpz_add($sum, $sum, $t);
    }
} 2, 252097800623;
