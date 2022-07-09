#!/usr/bin/perl

# Least prime p such that p^n + 1 is the product of n distinct primes.
# https://oeis.org/A280005

# Known terms:
#   2, 3, 13, 43, 73, 47, 457, 1697, 109, 8161, 10429, 13183, 30089, 66569, 5281

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::Prime::Util::GMP qw();
use experimental qw(signatures);

use Math::GMPz;

sub a($n) {

    my $z = Math::GMPz::Rmpz_init();

    for(my $p = 2; ; $p = next_prime($p)) {
        #say "Checking: $p";
        Math::GMPz::Rmpz_ui_pow_ui($z, $p, $n);
        Math::GMPz::Rmpz_add_ui($z, $z, 1);
        my $t = Math::GMPz::Rmpz_get_str($z, 10);
        #Math::Prime::Util::GMP::is_almost_prime($n, $t) || next;
        Math::Prime::Util::GMP::moebius($t) || next;
        if (Math::Prime::Util::GMP::prime_omega($t) == $n) {
            return $p;
        }
    }
}

foreach my $n (1..10) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 2
a(2) = 3
a(3) = 13
a(4) = 43
a(5) = 73
a(6) = 47
a(7) = 457
a(8) = 1697
a(9) = 109
a(10) = 8161
a(11) = 10429
a(12) = 13183
