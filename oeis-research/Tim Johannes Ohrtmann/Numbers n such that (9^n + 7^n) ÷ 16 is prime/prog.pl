#!/usr/bin/perl

# Numbers n such that (9^n + 7^n)/16 is prime.
# https://oeis.org/A301369

use 5.014;
use ntheory qw(is_prob_prime);
use Math::GMPz;

my $nine = Math::GMPz->new(9);
my $seven = Math::GMPz->new(7);

# a(7) > 17737

for (my $n = 17737; ; $n += 2) {
    say "Testing $n";
    if (is_prob_prime(($nine**$n + $seven**$n) >> 4)) {
        die "Found: $n\n";
    }
}
