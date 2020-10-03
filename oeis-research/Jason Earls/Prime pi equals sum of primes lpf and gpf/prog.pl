#!/usr/bin/perl

# Numbers k such that the number of primes <= k is equal to the sum of primes from the smallest prime factor of k to the largest prime factor of k.
# https://oeis.org/A074210

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);

sub isok {
    my ($n) = @_;
    my @f = factor($n);
    prime_count($n) == sum_primes($f[0], $f[-1]);
}

foreach my $n (4, 12, 30, 272, 4717, 5402, 18487, 20115, 28372, 33998, 111040, 115170, 456975, 821586, 1874660, 4029676, 4060029, 59497900, 232668002, 313128068, 529436220) {
    if (isok($n)) {
        say "$n -- ok";
    }
    else {
        say "$n -- not ok";
    }
}

my $from = prev_prime(529436220) - 1;
my $pi   = prime_count($from);

sub arithmetic_sum_discrete ($x, $y, $z) {
    (int(($y - $x) / $z) + 1) * ($z * int(($y - $x) / $z) + 2 * $x) / 2;
}

sub prime_sum_approx ($n) {
    $n * $n / 2 / log($n);
}

foreach my $n ($from .. $from + 1e5) {

    if (is_prime($n)) {
        ++$pi;
        next;
    }

    my @f = factor($n);

    if (prime_sum_approx($f[-1]) - prime_sum_approx($f[0]) > $pi) {
        next;
    }

    if (arithmetic_sum_discrete($f[0], $f[-1], 1) < $pi) {
        next;
    }

    if ($pi == sum_primes($f[0], $f[-1])) {
        say "Found: $n";
    }
}
