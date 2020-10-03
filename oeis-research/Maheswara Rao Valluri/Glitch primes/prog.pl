#!/usr/bin/perl

use 5.014;
#use ntheory qw(forprimes is_prime vecall prime_iterator lcm divisor_sum divisors);
use Math::Prime::Util::GMP qw(is_prob_prime);

# https://oeis.org/draft/A306661

# a(8)-a(9) from ~~~~

# Found: 4254

use Math::GMPz;
my $ten = Math::GMPz->new(10);

my $from = 5246;

foreach my $k($from..1e9) {

    say "Testking: $k";

    if (is_prob_prime(($ten**($k+3) + 111) * $ten**($k+1) + 1)) {
        say $k;
        if ($k > $from) {
            die "Found new term: $k";
        }
    }

    #(10^(k+3)+111)*10^(k+1)+1
}
