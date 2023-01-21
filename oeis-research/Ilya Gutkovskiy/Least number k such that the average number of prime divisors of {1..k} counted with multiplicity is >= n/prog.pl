#!/usr/bin/perl

# a(n) is the least number k such that the average number of prime divisors of {1..k} counted with multiplicity is >= n.
# https://oeis.org/A336304

# Known terms:
#   1, 4, 32, 2178, 416417176

use strict;
use warnings;

use 5.020;
use Math::AnyNum qw(bsearch_le);
use ntheory qw(:all);
use experimental qw(signatures);

sub sum_of_exponents_of_factorial_2 ($n) {

    my $s = sqrtint($n);
    my $total = 0;

    for my $k (1 .. $s) {
        $total += prime_power_count(divint($n,$k));
        $total += divint($n,$k) if is_prime_power($k);
    }

    $total -= prime_power_count($s) * $s;

    return $total;
}

sub a {
    my ($n) = @_;

    #return sum_of_exponents_of_factorial_2($n);

    return 0 if ($n <= 1);

    my $s = sqrtint($n);
    my $u = int($n/($s + 1));

    my $total = 0;
    my $prev = prime_power_count($n);

    for my $k (1 .. $s) {
        my $curr = prime_power_count(int($n/($k+1)));
        $total += $k * ($prev - $curr);
        $prev = $curr;
    }

    forprimes {
        foreach my $k (1 .. logint($u, $_)) {
            $total += int($n / $_**$k);
        }
    } $u;

    return $total;
}

my $n = 5;

my $x = 2;
my $y = 2*$x;

while (a($y) / $y < $n) {
    say "Checking range: ($x, $y)";
    ($x, $y) = ($y, 2*$y);
}

say "Sieving: ($x, $y)";

my $v = bsearch_le($x, $y, sub {
    my ($k) = @_;
    say "Checking: $k";
    a($k) / $k <=> $n;
});

say a($v)/$v;

#CORE::say a(416417176);
#printf("%s\n", join(', ', map { a($_) } 0..100));
