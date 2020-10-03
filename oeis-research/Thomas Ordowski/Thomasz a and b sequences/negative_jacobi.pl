#!/usr/bin/perl


use 5.014;
use ntheory qw(:all);

# Let b(n) be the smallest odd number k > 1 such that b^((k-1)/2) == -(b/k) (mod k) for every natural base b <= prime(n), where (b/k) is the Jacobi symbol.

sub foo {
    my ($n) = @_;

    my $p = nth_prime($n);
    my @primes = @{primes($p)};
    foreach my $k(3..1e10) {
        $k % 2 == 1 or next;
        if (vecall { powmod($_, ($k-1)>>1, $k) == ((-kronecker($_, $k))%$k) } @primes) {
            return $k;
        }

    }
}

foreach my $k(1..100) {
    say "a($k) = ", foo($k);
}
