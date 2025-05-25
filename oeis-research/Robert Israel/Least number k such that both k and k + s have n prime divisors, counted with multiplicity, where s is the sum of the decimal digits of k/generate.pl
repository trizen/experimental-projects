#!/usr/bin/perl

# a(n) is the least number k such that both k and k + s have n prime divisors, counted with multiplicity, where s is the sum of the decimal digits of k.
# https://oeis.org/A382996

# Known terms:
#   11, 15, 18, 81, 243, 486, 2976, 25488, 128768, 396864, 911232, 8820864, 69940224, 118462464, 1171768320, 1756943946, 11753349120, 272313556992, 491737042890, 2374758457344, 9766784434176, 22675979501496

# New terms:
#   a(23) = 269744252387328
#   a(24) = 1546075329527736
#   a(25) = 6138628058382336

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, if(bigomega(m*q+sumdigits(m*q)) == k, listput(list, m*q))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
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
                if (is_almost_prime($n, $m*$_ + sumdigits($m*$_))) {
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

my $n     = 25;
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
a(24) <= 1808197575376896
a(24) <= 1546075329527736
perl generate.pl  466.55s user 0.85s system 83% cpu 9:17.66 total

a(25) <= 7662027408408576
a(25) <= 6138628058382336
perl generate.pl  837.56s user 0.87s system 82% cpu 16:53.95 total
