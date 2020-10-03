#!/usr/bin/perl

# Numbers n such that lcm(sigma(n), n) = tau(n) * sigma(n) where sigma(k) = the sum of the divisors of k (A000203) and tau(k) = the number of divisors of k (A000005).
# https://oeis.org/A306655

use 5.014;
use ntheory qw(forprimes is_prime vecall prime_iterator lcm divisor_sum divisors);

my $k = 16;
for my $n(65544192..1e10) {
    my $sigma = divisor_sum($n);
    my $sigma0 = divisors($n);

    if (lcm($sigma , $n) == $sigma0*$sigma) {
        say "a($k) = ", $n;
        ++$k;
    }
}

__END__

% perl x.pl                                                             » /tmp «
a(16) = 65544192
a(17) = 752903424
^C
perl x.pl  1867.61s user 1.57s system 98% cpu 31:44.30 total
