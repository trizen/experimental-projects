#!/usr/bin/perl

# a(n) is the least odd number k such that Omega(k) = n, Omega(k+2) = n+1, and Omega(k+4) = n+2, where Omega(k) is the number of prime factors of k (A001222).
# https://oeis.org/A335496

# Known terms:
#   23, 871, 5423, 229955, 13771373, 558588875, 21549990623, 1325878234371

# Upper-bounds:
#   a(10) <= 429205867309373

# New terms:
#   a(9) = 17040894859373
#   a(10) = 429205867309373

# Formula:
#   a(n) >= A335498(n). - ~~~~

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(bigomega(t-4) == k && bigomega(t-2) == k+1, listput(list, t-4))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n+2, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

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

my $n     = 10;
my $lo    = powint(2, $n);
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi,
        $n + 2,
        sub ($k) {
            if ($k < $limit and is_almost_prime($n+1, $k - 2) and is_almost_prime($n, $k-4)) {
                say "a(", $n, ") <= ", $k - 4;
                $limit = $k;

            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}

__END__
Sieving range: [206695301119, 413390602238]
Sieving range: [413390602239, 826781204478]
Sieving range: [826781204479, 1653562408958]
a(8) <= 1325878234371
perl generate.pl  278.61s user 0.47s system 92% cpu 5:02.92 total

Sieving range: [3302829850623, 6605659701246]
Sieving range: [6605659701247, 13211319402494]
Sieving range: [13211319402495, 26422638804990]
a(9) <= 17040894859373
perl generate.pl  1359.83s user 2.16s system 95% cpu 23:51.50 total
