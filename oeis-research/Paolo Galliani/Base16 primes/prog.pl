#!/usr/bin/perl

# Non negative integers j such that 2^j-1 in base 10 converted in base 16 is a prime p in base 10.
# https://oeis.org/A307226 (recyclied)
# 2, 3, 9, 11, 87, 233, 477, 507, 785, 2313, 8967

use 5.014;
#use ntheory qw(:all);
use Math::Prime::Util::GMP qw(is_prob_prime);

use Math::GMPz;
my $z = Math::GMPz::Rmpz_init_set_ui(1);
my $t = Math::GMPz::Rmpz_init_set_ui(1);

local $| = 1;

foreach my $k(1..1e5) {
    Math::GMPz::Rmpz_mul_2exp($z, $z, 1);

    $k >= 1e4 or next;
    Math::GMPz::Rmpz_sub_ui($t, $z, 1);
    Math::GMPz::Rmpz_set_str($t, Math::GMPz::Rmpz_get_str($t, 10), 16);

    if (is_prob_prime($t)) {
        print "$k, ";
    }
}
