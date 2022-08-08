#!/usr/bin/perl

# a(n) is the first prime that starts a sequence of exactly n consecutive primes prime(k+1), ..., prime(k+n) where prime(k+i)+2^i is prime for i = 1...n but not for i = n+1.
# https://oeis.org/A356074

# Known terms:
#   3, 11, 17, 5, 37307, 17387, 87020177, 1309757957

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

my $n           = 9;
my $lower_bound = 1309757957;

my $k = prime_count($lower_bound);

my @Q;
my $p = nth_prime($k);

for (1 .. $n) {
    push @Q, $p;
    $p = next_prime($p);
}

say $Q[-1];
say nth_prime($k + $n - 1);

say $Q[0];
say nth_prime($k);

say join ' ', map { nth_prime($_) + 2**($_ - $k + 1) } $k .. $k + $n - 1;
say join ' ', map { $Q[$_] + 2**($_ + 1) } 0 .. $n - 1;

forprimes {

    if (is_prime($Q[0] + 2) && is_prime($Q[-1] + (1 << $n)) && vecall { is_prime($Q[$_] + (1 << ($_ + 1))) } 1 .. $n - 2) {
        die "a($n) = $Q[0]\n";
    }

    shift @Q;
    push @Q, $_;
} $p, 1e13;
