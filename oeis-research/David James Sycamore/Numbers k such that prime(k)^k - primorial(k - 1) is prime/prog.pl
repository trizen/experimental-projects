#!/usr/bin/perl

# Numbers k such that prime(k)^k - primorial(k - 1) is prime.
# https://oeis.org/A305076

use 5.014;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(next_prime nth_prime);
use Math::Prime::Util::GMP qw(pn_primorial is_prob_prime);

my $p         = Math::GMPz::Rmpz_init();
my $primorial = Math::GMPz::Rmpz_init();

my $from      = 4366;
my $nth_prime = nth_prime($from);

Math::GMPz::Rmpz_set_str($primorial, pn_primorial($from - 1), 10);

foreach my $k ($from .. 1e6) {

    Math::GMPz::Rmpz_ui_pow_ui($p, $nth_prime, $k);
    Math::GMPz::Rmpz_sub($p, $p, $primorial);

    say "Testing: $k";

    if (is_prob_prime(Math::GMPz::Rmpz_get_str($p, 10))) {
        say "Found: $k";
        die "!!!!! HAPPY !!!!!";
    }

    Math::GMPz::Rmpz_mul_ui($primorial, $primorial, $nth_prime);
    $nth_prime = next_prime($nth_prime);
}
