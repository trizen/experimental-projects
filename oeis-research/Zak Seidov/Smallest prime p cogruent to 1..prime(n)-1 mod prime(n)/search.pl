#!/usr/bin/perl

use 5.014;
use warnings;
use ntheory qw(:all);

# Smallest prime q such that, starting with q, there are prime(n)-1 consecutive primes = {1..prime(n)-1} modulo prime(n).
# https://oeis.org/A206333

# Known terms:
#     3, 7, 251, 61223, 23700022897

my $from = prev_prime(59967907);
my @root = $from;

while (@root < 11) {
    $from = next_prime($from);
    push @root, $from;
}

forprimes {

    if ($_ % 13 == 12 and $root[0]%13 == 1) {

        my $ok = 1;
        foreach my $k(2..11) {
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
