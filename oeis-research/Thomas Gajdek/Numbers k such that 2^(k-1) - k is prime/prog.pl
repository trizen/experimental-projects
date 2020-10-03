#!/usr/bin/perl

# Numbers k such that 2^(k-1) - k is prime.
# https://oeis.org/A296031

use 5.014;
use Math::Prime::Util::GMP qw(is_prob_prime);

use Math::GMPz;
my $one = Math::GMPz->new(1);

# From: 65117

foreach my $k(65117..80000) {
    say "Testing: $k";
    if (is_prob_prime(($one << ($k-1)) - $k)) {
        die "\nFound: $k\n";
    }
}
