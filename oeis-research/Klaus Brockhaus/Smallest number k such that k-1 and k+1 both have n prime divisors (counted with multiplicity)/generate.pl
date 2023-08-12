#!/usr/bin/perl

# a(n) = smallest number k such that k-1 and k+1 both have n prime divisors (counted with multiplicity).
# https://oeis.org/A154704

# Known terms:
#   4, 5, 19, 55, 271, 1889, 10529, 59777, 101249, 406783, 6581249, 12164095, 65071999, 652963841, 6548416001, 13858918399, 145046192129, 75389157377, 943344975871, 23114453401601, 108772434771967, 101249475018751, 551785225781249

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, if(bigomega(m*q+2) == k, listput(list, m*q+1))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

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

my $n     = 19;
my $lo    = powint(2, $n);
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

#$lo = "2538577986229192";
#$hi = "205337027587890626";
#$limit = $hi+1;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi, $n,
        sub ($k) {
            if ($k < $limit and is_almost_prime($n, $k + 2)) {
                say "a(", $n, ") <= ", $k + 1;
                $limit = $k;
            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}
