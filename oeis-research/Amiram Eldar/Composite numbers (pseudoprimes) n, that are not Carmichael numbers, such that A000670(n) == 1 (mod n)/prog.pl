#!/usr/bin/perl

# Composite numbers (pseudoprimes) n, that are not Carmichael numbers, such that A000670(n) == 1 (mod n).
# https://oeis.org/A289338

# Known terms:
#   169, 885, 2193, 8905, 22713

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

sub modular_fubini_number {
    my ($n, $m) = @_;

    my @F = (1);

    foreach my $i (1 .. $n) {
        foreach my $k (0 .. $i - 1) {
            $F[$i] += mulmod($F[$k], binomialmod($i, $i - $k, $m), $m);
        }
    }

    $F[-1] % $n;
}

foreach my $n (1..1e6) {

    next if is_prime($n);
    next if is_carmichael($n);

    if (modular_fubini_number($n, $n) == 1) {
        say "Found term: $n";
    }
}

__END__
Found term: 169
Found term: 885
