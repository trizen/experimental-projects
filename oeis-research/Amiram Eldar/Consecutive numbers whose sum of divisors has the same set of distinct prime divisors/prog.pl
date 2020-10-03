#!/usr/bin/perl

# a(n) begins the first run of least n consecutive numbers whose sum of divisors has the same set of distinct prime divisors.
# https://oeis.org/A303693

# Known terms:
#   1, 5, 33, 3777, 20154, 13141793, 11022353993

use 5.014;
use ntheory qw(divisor_sum factor_exp);

my $k = 6;

# a(7) > 1e9

#foreach my $n(2..10000) {
for (my $n = 1e10; $n <= 1e11; ) {

    my $d = join ' ', map{$_->[0]} factor_exp(divisor_sum($n));

    my $c = 0;
    my $t = $n+1;

    while (join(' ', map{$_->[0]} factor_exp(divisor_sum($t))) eq $d) {

        ++$c;
        ++$t;

        if ($c == $k) {
            ++$k;
            say $n;
        }
    }

    $n = $t;
}
