#!/usr/bin/perl

use 5.014;
#use ntheory qw(forprimes is_prime vecall prime_iterator lcm divisor_sum divisors);
use Math::Prime::Util::GMP qw(is_prob_prime);

# https://oeis.org/draft/A306660

use Math::GMPz;
my $ten = Math::GMPz->new(10);

my $from = 12001;

foreach my $k($from..1e9) {

    say "Testing: $k";

    if (is_prob_prime(($ten**($k+3) + 999) * $ten**($k+1) + 1)) {
        say $k;
        if ($k > $from) {
            die "Found new term: $k";
        }
    }

    #(10^(k+3)+111)*10^(k+1)+1
}

# Numbers k such that ((10^(k+3)+999)*10^(k+1)+1) is prime.

# For k=2, 100999001 is prime, so 2 is a term.

# Do[ If[ PrimeQ[((10^(k+3)+999)*10^(k+1)+1)], Print@ k], {k, 1000}]

# (PARI) isok(k) = ispseudoprime((10^(k+3)+999)*10^(k+1)+1);
