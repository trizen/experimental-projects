#!/usr/bin/perl

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use Math::AnyNum;
use ntheory qw(:all);
use experimental qw(signatures);

sub primality_pretest ($k) {
    !(!($k %  3) || !($k %  5) || !($k %  7) || !($k % 11) ||
        !($k % 13) || !($k % 17) || !($k % 19) || !($k % 23)
    )
}

my $k = 8128;
my @divisors = divisors($k);
pop @divisors;

sub isok($m) {

    foreach my $d(@divisors) {
        if (!primality_pretest($k*$d*$m - 1)) {
            return 0;
        }
    }

    foreach my $d(@divisors) {
        if (!is_prime($k*$d*$m - 1)) {
            return 0;
        }
    }

    return 1;
}

my $multiplier = 3*3*5;

foreach my $n(99098813-100..1e10) {
    if (isok($n*$multiplier)) {
        say "Found: $n -> ", $n*$multiplier;
        last;
    }
}
