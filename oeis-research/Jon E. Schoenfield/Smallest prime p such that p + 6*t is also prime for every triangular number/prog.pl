#!/usr/bin/perl

# a(n) is the smallest prime p such that p + 6*t is also prime for every triangular number t up to, but not including, the n-th triangular number (or 0 if no such prime exists).
# https://oeis.org/A323740

use 5.014;
use ntheory qw(forprimes is_prime vecall prime_iterator);

sub a {
    my ($n) = @_;

    my @triangulars = reverse(map { 6 * $_ * ($_ + 1) / 2 } 1 .. $n);
    my $extra       = shift(@triangulars);
    my $iter        = prime_iterator();

    forprimes {
        my $p = $_;
        if (not(is_prime($p + $extra)) and vecall { is_prime($p + $_) } @triangulars) {
            die "Found: $p";
        }
    } 5 * 1e11, 1e12;
}

for my $n (14) {
    say "a($n) = ", a($n);
}
