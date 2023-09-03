#!/usr/bin/perl

# a(n) is the smallest positive number k such that k^2 - 1 and k^2 + 1 each have n distinct prime divisors.
# https://oeis.org/A365326

# Known terms:
#   2, 5, 13, 83, 463, 4217, 169333, 2273237, 23239523, 512974197, 5572561567

# a(n) >= max(A219017(n), A180278(n)).

use 5.036;
use ntheory qw(:all);

my @lower_bounds = (0, 2, 4, 13, 47, 447, 2163, 24263, 241727, 2923783, 16485763, 169053487, 4535472963);

sub a($n) {
    #my $min = sqrtint(pn_primorial($n));
    my $min = $lower_bounds[$n];

    for(my $k = $min; ; ++$k) {
        if (is_omega_prime($n, mulint($k, $k) - 1) and is_omega_prime($n, mulint($k, $k) + 1)) {
            return $k;
        }
    }
}

foreach my $n(2..20) {
    say "a($n) = ", a($n);
}

__END__
a(2) = 5
a(3) = 13
a(4) = 83
a(5) = 463
a(6) = 4217
a(7) = 169333
a(8) = 2273237
a(9) = 23239523
