#!/usr/bin/perl

# Numbers k such that 3^k + k - 1 is a prime.
# http://oeis.org/A300010

use 5.014;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(is_prob_prime is_prime);

my $three = Math::GMPz->new(3);

# a(11) > 55145

for (my $k = 55145; ; $k += 2) {
    next if ($k%3 == 1);

    say "Testing $k";
    if (is_prob_prime($three**$k + ($k-1))) {
        die "Found: $k\n";
    }
}
