#!/usr/bin/perl

# a(n) is the least number k such that omega(k) = n and the largest prime factor of k equals the sum of its remaining prime factors, where omega(k) = A001221(k).
# https://oeis.org/A383725

=for comment

# Pari/GP program:

generate(A, B, n) = A=max(A, vecprod(primes(n))); (f(m, p, j, s) = my(list=List()); if(j==1, if(isprime(s), listput(list, m*s)); return list); forprime(q=p, sqrtnint(B\m, j), my(v=m*q, r=nextprime(q+1)); while(v <= B, if(v*r <= B, list=concat(list, f(v, r, j-1, s+q))); v *= q)); list); vecsort(Vec(f(1, if(n%2 == 0, 3, 2), n, 0)));
a(n) = my(x=vecprod(primes(n)), y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

use 5.020;
use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMPz;

sub omega_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k, $sum) {

        my $s = rootint(divint($B, $m), $k);

        if ($k == 1) {
            if (is_prime($sum)) {
                $callback->($m*$sum);
            }
            return;
        }

        foreach my $q (@{primes($p, $s)}) {

            my $r = next_prime($q);
            my $new_sum = $sum + $q;

            for (my $v = $m * $q ; $v <= $B ; $v *= $q) {
                if ($k == 1) {
                   # $callback->($v) if ($v >= $A);
                }
                elsif ($v * $r <= $B) {
                    __SUB__->($v, $r, $k - 1, $new_sum);
                }
            }
        }
    }->(Math::GMPz->new(1), (($k % 2 == 0) ? 3 : 2), $k, 0);
}

my $n = 19;
my $lo = pn_primorial($n);
my $hi = 2*$lo;
my $limit = 0+'inf';

while (1) {

    omega_prime_numbers($lo, $hi, $n, sub($k) {
        if ($k < $limit) {
            say "a($n) <= $k";
            $limit = $k;
        }
    });

    last if $hi > $limit;

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
a(19) <= 83465104039844216449389630
a(19) <= 67794672364404337821058590
perl generate.pl  45.88s user 0.01s system 99% cpu 45.985 total
