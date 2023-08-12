#!/usr/bin/perl

# a(n) is the smallest prime p such that p-1 and p+1 both have n prime factors (with multiplicity).
# https://oeis.org/A154598

# Known terms:
#   5, 19, 89, 271, 1889, 10529, 75329, 157951, 3885569, 11350529, 98690561, 65071999, 652963841, 6548416001, 253401579521, 160283668481, 1851643543553, 3450998226943, 23114453401601, 1194899749142527, 1101483715526657, 7093521158963201

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, if(isprime(m*q+1) && bigomega(m*q+2) == k, listput(list, m*q+1))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

# Lower-bounds:
#   a(24) > 2^54. - Jon E. Schoenfield, Feb 08 2009

use 5.036;
use ntheory qw(:all);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    my $n = $k;
    $A = vecmax($A, powint(2, $k));

    sub ($m, $p, $k) {

        if ($k == 1) {

            forprimes {
                if (is_almost_prime($n, $m * $_ + 2)) {
                    $callback->($m * $_);
                }
            }
            vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(1, 2, $k);
}

my $n     = 24;
my $lo    = powint(2, $n);
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

$lo = powint(2, 54);
$hi = 2*$lo;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi, $n,
        sub ($k) {
            if ($k < $limit and is_prime($k+1) and is_almost_prime($n, $k + 2)) {
                say "a(", $n, ") <= ", $k + 1;
                $limit = $k;
            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}
