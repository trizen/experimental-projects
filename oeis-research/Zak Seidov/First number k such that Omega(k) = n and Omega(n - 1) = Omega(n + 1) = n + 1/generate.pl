#!/usr/bin/perl

# a(n) is the first number k such that Omega(k) = n and Omega(n - 1) = Omega(n + 1) = n + 1.
# https://oeis.org/A369295

# Known terms:
#   5, 51, 343, 3185, 75951, 1780624, 16825375, 212781249

# New terms:
#   a(9) = 4613781249
#   a(10) = 74239460225
#   a(11) = 858245781249

use 5.036;
use ntheory qw(:all);

sub a($n) {

    my $lo = 2;
    my $hi = 2 * $lo;

    while (1) {

        foreach my $k (@{almost_primes($n+1, $lo, $hi)}) {
            if (is_almost_prime($n+1, $k+2) and is_almost_prime($n, $k+1)) {
                return $k + 1;
            }
        }

        $lo = $hi + 1;
        $hi = int(1.001 * $lo);
    }

}

foreach my $n (12) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 5
a(2) = 51
a(3) = 343
a(4) = 3185
a(5) = 75951
a(6) = 1780624
a(7) = 16825375
a(8) = 212781249
a(9) = 4613781249
a(10) = 74239460225
a(11) = 858245781249

# PARI/GP program:

generate(A, B, n) = A=max(A, 2^n); (f(m, p, k) = my(list=List()); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(bigomega(t+2) == n && bigomega(t+1) == n-1, listput(list, t+1))), forprime(q = p, sqrtnint(B\m, k), my(t=m*q); if(ceil(A/t) <= B\t, list=concat(list, f(t, q, k-1))))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n+1)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# PARI/GP program (a bit simpler):

generate(A, B, n) = A=max(A, 2^n); (f(m, p, k) = my(list=List()); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(bigomega(t+2) == n && bigomega(t+1) == n-1, listput(list, t+1))), forprime(q = p, sqrtnint(B\m, k), list=concat(list, f(m*q, q, k-1)))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n+1)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~
