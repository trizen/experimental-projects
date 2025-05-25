#!/usr/bin/perl

# a(n) is the least number k such that k, k - s and k + s all have n prime divisors, counted with multiplicity, where s is the sum of the decimal digits of k.
# https://oeis.org/A383665

# New terms:
#   a(16) = 6373064359936
#   a(17) = 186505184249928

# Lower-bounds:
#   a(17) > 170293660137554

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, my(s=sumdigits(m*q)); if(bigomega(m*q+s) == k && bigomega(m*q-s) == k, listput(list, m*q))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
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
                if (is_almost_prime($n, $m*$_ + sumdigits($m*$_))
                and is_almost_prime($n, $m*$_ - sumdigits($m*$_))) {
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

my $n     = 17;
my $lo    = powint(2, $n);
my $hi    = 2*$lo;
my $limit = 'inf' + 0;

$lo = 140738562097151;
$hi = int(1.1 * $lo);

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
    $hi = int(1.1 * $lo);
}

__END__
Sieving range: [170293660137554, 187323026151309]
a(17) <= 186505184249928
perl generate.pl  1316.37s user 1.21s system 96% cpu 22:43.51 total
