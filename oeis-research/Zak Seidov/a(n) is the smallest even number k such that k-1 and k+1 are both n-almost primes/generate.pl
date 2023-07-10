#!/usr/bin/perl

# a(n) is the smallest even number k such that k-1 and k+1 are both n-almost primes.
# https://oeis.org/A335667

# Known terms:
#   4, 34, 274, 2276, 8126, 184876, 446876, 18671876, 95234374, 1144976876, 6018359374, 281025390626, 2068291015624, 6254345703124

# Upper-bounds:
#   a(12) <= 373434359374
#   a(17) <= 38672585205078124

# Lower-bounds:
#   a(17) > 27021735203176447

# New terms:
#   a(15) = 181171630859374
#   a(16) = 337813720703126
#   a(17) = 31079046044921876
#   a(18) = 205337027587890626

=for comment

# Pari/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, if(bigomega(m*q+2) == k, listput(list, m*q+1))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 3, n)));
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
                if (is_almost_prime($n, $m*$_ + 2)) {
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
      ->(1, 3, $k);
}

my $n     = 18;
my $lo    = powint(2, $n);
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

$lo = "2538577986229192";
$hi = "205337027587890626";
$limit = $hi+1;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi,
        $n,
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
