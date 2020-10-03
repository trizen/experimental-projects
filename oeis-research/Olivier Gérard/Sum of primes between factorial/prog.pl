#!/usr/bin/perl

# a(n) is the sum of primes between n!+1 and (n+1)!.
# https://oeis.org/A294194

use 5.014;
use Math::GMPz qw();
use Math::MPFR qw(MPFR_RNDZ);
use ntheory qw(forprimes factorial sum_primes);

# Found:
#   a(15) = 7225340509057562100376047

for my $n (2..100) {
    say "a($n) = ", sum_primes(factorial($n)+1, factorial($n+1));
}
