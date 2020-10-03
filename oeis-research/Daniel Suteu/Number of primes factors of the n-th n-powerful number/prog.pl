#!/usr/bin/perl

# Let a(n) be the number of prime factors counted with multiplicty of the n-th n-powerful number.

use 5.014;
use warnings;

use ntheory qw(:all);

for my $k (1..1000) {
    say "$k ", prime_bigomega(nth_powerful($k,$k));
}
