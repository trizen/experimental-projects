#!/usr/bin/perl

use 5.014;
#use ntheory qw(forprimes is_prime vecall prime_iterator lcm divisor_sum divisors);
use Math::Prime::Util::GMP qw(is_prob_prime is_prime);

# https://oeis.org/draft/A306659

# 2091

use Math::GMPz;
my $ten = Math::GMPz->new(10);

my $last = 3950;

foreach my $k($last..1e9) {

    say "Testing: $k";

    if (is_prob_prime(($ten**($k+3) + 888) * $ten**($k+1) + 1)) {
        say $k;
        if ($k > $last) {
            die "Found new term: $k";
        }
    }

    #(10^(k+3)+111)*10^(k+1)+1
}
