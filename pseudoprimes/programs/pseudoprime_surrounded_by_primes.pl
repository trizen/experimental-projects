#!/usr/bin/perl

# Pseudoprimes n to base 2 such that n-2, n+2, n-4 and n+4 are primes.
# https://oeis.org/A228455

# Known terms:
#   280743771536011785, 666787209284980785, 1386744766793550165, 6558237049521329745, 11646802313400102465

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    is_pseudoprime($n, 2) || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    if (is_prime($n - 2) and is_prime($n - 4) and is_prime($n + 2) and is_prime($n + 4)) {
        say $n if !$seen{$n}++;

        if ($n > 11646802313400102465) {
            die "Found new term: $n";
        }
    }
}
