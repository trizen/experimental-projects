#!/usr/bin/perl

# Let a(n) be the smallest odd prime p such that q^((p-1)/2) == -1 (mod p) for every prime q <= prime(n).

# Let b(n) be the smallest odd composite k such that q^((k-1)/2) == -1 (mod k) for every prime q <= prime(n).

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

$| = 1;

sub isok_a {
    my ($n, $p) = @_;

    $p % 2 == 1 or return;
    is_prime($p) or return;

    my @primes = @{primes(nth_prime($n))};
    vecall { powmod($_, ($p-1)>>1, $p) == $p-1 } @primes;
}

sub a {
    my ($n) = @_;

    for(my $p = 3; ; $p = next_prime($p)) {
        if (isok_a($n, $p)) {
            return $p;
        }
    }
}

sub isok_b {
    my ($n, $k) = @_;

    $k % 2 == 1 or return;
    is_prime($k) and return;

    my @primes = @{primes(nth_prime($n))};
    vecall { powmod($_, ($k-1)>>1, $k) == $k-1 } @primes;
}

sub b {
    my ($n) = @_;

    for(my $k = 3; ; $k += 2) {
        if (isok_b($n, $k)) {
            return $k;
        }
    }
}

foreach my $k(1..100) {
   print (b($k),  ", ");
}
