#!/usr/bin/perl

use 5.014;
use warnings;
use ntheory qw(:all);

# Primes p such that 8 consecutive primes starting with p are {1,2,3,4,5,6,7,8} modulo 13.
# https://oeis.org/A338394

# Known terms:
#    5129602609, 40602028559, 69528307577, 129007460609, 236659873633

# New terms found:
#   322320688171, 371170549153,

my $from = prev_prime(371170549153-1e6);
my @root = $from;

while (@root < 7) {
    $from = next_prime($from);
    push @root, $from;
}

forprimes {

    if ($_ % 13 == 8 and $root[0]%13 == 1) {

        my $ok = 1;

        foreach my $k (2..7) {
            if (($root[$k-1] % 13) != $k) {
                $ok = 0;
                last;
            }
        }
        say $root[0] if $ok;
    }

    push @root, $_;
    shift @root;

} next_prime($from), 1e14;
