#!/usr/bin/perl

# a(n) is the first prime that starts a sequence of exactly n consecutive primes prime(k+1), ..., prime(k+n) where prime(k+i)+2^i is prime for i = 1...n but not for i = n+1.
# https://oeis.org/A356074

# Known terms:
#   3, 11, 17, 5, 37307, 17387, 87020177, 1309757957

# Upper-bounds:
#   a(9) <= 814442926307

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

my $n   = 10;
my $sum = 2;

my @acc = ($sum);
for (2 .. $n - 3) {
    $sum += (1 << $_);
    push @acc, $sum;
}

#~ my $min = 2;
#~ my $max = 1309757957;

my $min = 416994778269184;
my $max = 2*$min;

for (my $k = 1 ; ; ++$k) {

    say "[$k] Sieving range ($min, $max)";

    my $found = 0;
    my @arr   = sieve_prime_cluster($min, $max, @acc);

    say "Checking ", scalar(@arr), " primes...";

    foreach my $p (@arr) {

        my @primes = ($p);
        for (1 .. $n - 1) {
            push @primes, next_prime($primes[-1]);
        }

        if (is_prime($primes[-1] + (1<<$n)) and vecall { is_prime($primes[$_] + (1 << ($_ + 1))) } 0 .. $n - 1) {
            say "a($n) <= $primes[0]";
            $found = 1;
            last;
        }
    }

    last if $found;
    ($min, $max) = ($max, 2 * $max);
}
