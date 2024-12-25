#!/usr/bin/perl

# a(n) is the least prime prime(k) such that prime(k+n-1)^2 - prime(k)^2 + prime(i) for i=k..k+n-1 are consecutive primes.
# https://oeis.org/A352392

# Known terms:
#   2, 5, 5, 37, 3181, 641, 1157111, 181995731

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

#my $n = 7;
#my $lower_bound = 2;

my $n = 9;
my $lower_bound = 19723461071;

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

say join ' ', map { nth_prime($k + $n - 1)**2 - nth_prime($k)**2 + nth_prime($_) } $k .. $k + $n - 1;
say join ' ', map { $Q[-1]**2 - $Q[0]**2 + $Q[$_] } 0 .. $n - 1;

sub isok ($n, $p) {

    my $k = prime_count($p);
    my $r = powint(nth_prime($k + $n - 1), 2) - powint(nth_prime($k), 2);

    my @list;
    my @list2;

    foreach my $i ($k .. $k + $n - 1) {
        push @list, $r + nth_prime($i);
    }

    my $q = $list[0];
    push @list2, next_prime($q - 1);

    for (1 .. $n - 1) {
        $q = next_prime($q);
        push @list2, $q;
    }

    if ("@list" eq "@list2") {
        return 1;
    }

    die "Error: (@list) != (@list2)";
}

my $count = 0;

forprimes {

    if (++$count % 1e7 == 0) {
        say "Checking: $_"
    }

    my $r = $Q[-1] * $Q[-1] - $Q[0] * $Q[0];
    my $t = $r + $Q[0];

    if (is_prime($t)) {

        my $found = 1;

        foreach my $i (1 .. $n - 1) {
            $t = next_prime($t);
            if ($t != $r + $Q[$i]) {
                $found = 0;
                last;
            }
        }

        if ($found) {
            isok($n, $Q[0]);
            die "a($n) = $Q[0]\n";
        }
    }

    shift @Q;
    push @Q, $_;
} $p, 1e13;
