#!/usr/bin/perl

use 5.014;
use Math::Prime::Util::GMP qw(lucasu is_prob_prime);

# Indices of prime Pell numbers.
# https://oeis.org/A096650

# From: 100069

foreach my $n(100069..200000) {
    say "Testing: $n";
    die "\nFound: $n\n" if is_prob_prime(lucasu(2, -1, $n));
}
