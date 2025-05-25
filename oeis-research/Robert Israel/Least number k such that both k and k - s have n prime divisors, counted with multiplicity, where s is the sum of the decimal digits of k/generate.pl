#!/usr/bin/perl

# a(n) is the least number k such that both k and k - s have n prime divisors, counted with multiplicity, where s is the sum of the decimal digits of k.
# https://oeis.org/A381851

# Known terms:
#   10, 20, 40, 80, 224, 448, 2176, 24640, 98816, 287744, 3771392, 5637632, 6508544, 323903488, 1126252544, 7698939904, 20511260672, 249460531200, 857557762048, 582799458304, 11797582053376, 24614476447744

# New terms:
#   a(24) = 591901367468032
#   a(25) = 1314105503776768
#   a(26) = 5988418763882496

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, my(s=sumdigits(m*q)); if(m*q > s && bigomega(m*q-s) == k, listput(list, m*q))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
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
                if (is_almost_prime($n, $m*$_ - sumdigits($m*$_))) {
                    $callback->($m * $_);
                }
            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(1, 2, $k);
}

my $n     = 26;
my $lo    = powint(2, $n);
my $hi    = 2*$lo;
my $limit = 'inf' + 0;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi,
        $n,
        sub ($k) {
            if ($k < $limit) {
                say "a(", $n, ") <= ", $k;
                $limit = $k;
            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}

__END__
a(24) <= 765765326209024
a(24) <= 591901367468032
perl generate.pl  229.85s user 0.42s system 75% cpu 5:04.65 total

Sieving range: [1125899940397055, 2251799880794110]
a(25) <= 1314105503776768
perl generate.pl  204.60s user 0.33s system 63% cpu 5:23.12 total

Sieving range: [4503599694479359, 9007199388958718]
a(26) <= 5988418763882496
perl generate.pl  422.08s user 1.93s system 47% cpu 14:51.56 total
