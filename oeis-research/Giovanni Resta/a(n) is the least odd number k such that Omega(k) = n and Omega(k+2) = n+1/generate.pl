#!/usr/bin/perl

# a(n) is the least odd number k such that Omega(k) = n and Omega(k+2) = n+1, where Omega(k) is the number of prime factors of k (A001222).
# https://oeis.org/A335498

# Previously known terms:
#   1, 7, 25, 873, 1375, 41875, 903123, 1015623, 49671873, 200921875, 1157734375, 41898828123

# Upper-bounds:
#   a(15) <= 417391474609375
#   a(16) <= 21282678548828125
#   a(16) <= 21270222900390625
#   a(17) <= 46804302197265625

# Lower-bounds:
#   a(19) > 360287970189639679

# New terms:
#   a(12) = 496308203125
#   a(13) = 10506958984375
#   a(14) = 7739037109375
#   a(15) = 382999267578123
#   a(16) = 17016876976778523
#   a(17) = 46804302197265625
#   a(18) = 80713609326109375

# PARI/GP program:

=for comment

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p,ceil(A/m)), B\m, my(t=m*q); if(bigomega(t-2) == k, listput(list, t-2))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n+1, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

use 5.036;
use ntheory qw(:all);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(2, $k));

    sub ($m, $p, $k) {

        if ($k == 1) {

            forprimes {
                $callback->($m * $_);
            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(1, 3, $k);
}

my $n     = 19;
my $lo    = 1;
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi,
        $n + 1,
        sub ($k) {
            if ($k < $limit and is_almost_prime($n, $k - 2)) {
                say "a(", $n, ") <= ", $k - 2;
                $limit = $k;

            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}
