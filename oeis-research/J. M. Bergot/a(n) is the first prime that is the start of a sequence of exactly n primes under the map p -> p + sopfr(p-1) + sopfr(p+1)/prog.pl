#!/usr/bin/perl

# a(n) is the first prime that is the start of a sequence of exactly n primes under the map p -> p + A001414(p-1) + A001414(p+1).
# https://oeis.org/A354386

# Known terms:
#   3, 2, 337, 2633, 14143, 6108437, 373777931

use 5.014;
use ntheory qw(:all);

my @table;

forprimes {

    my $count = 0;
    my $x = $_;

    do {
        $x = $x + vecsum(factor($x-1)) + vecsum(factor($x+1));
        ++$count;
    } while (is_prime($x));

    if (not $table[$count]) {
        $table[$count] = $_;
        say "a($count) = $_";
    }
} 1e13;
