#!/usr/bin/perl

# Numbers k such that 5^k + 2*k is a prime.
# https://oeis.org/A303090

use 5.014;
use warnings;

# Next term > 21000

use Math::GMPz;
use Math::Prime::Util::GMP qw(is_prob_prime);

my $t = Math::GMPz::Rmpz_init();

foreach my $n(21000..30000) {
    say "Trying $n";

    Math::GMPz::Rmpz_ui_pow_ui($t, 5, $n);
    Math::GMPz::Rmpz_add_ui($t, $t, 2*$n);

    if (is_prob_prime($t)) {
        die "Found: $n\n";
    }
}
