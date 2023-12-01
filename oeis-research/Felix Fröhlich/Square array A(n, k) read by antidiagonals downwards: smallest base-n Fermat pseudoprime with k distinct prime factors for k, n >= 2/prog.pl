#!/usr/bin/perl

# Square array A(n, k) read by antidiagonals downwards: smallest base-n Fermat pseudoprime with k distinct prime factors for k, n >= 2.
# https://oeis.org/A271873

# Previously known terms:
#   341, 561, 91, 11305, 286, 15, 825265, 41041, 435, 124, 45593065, 825265, 11305, 561, 35

# New terms:
#   341, 561, 91, 11305, 286, 15, 825265, 41041, 435, 124, 45593065, 825265, 11305, 561, 35, 370851481, 130027051, 418285, 41041, 1105, 6, 38504389105, 2531091745, 30534805, 2203201, 25585, 561, 21, 7550611589521, 38504389105, 370851481, 68800501, 682465, 62745, 105, 28

=for comment

# PARI/GP program (VERSION 2)

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0, listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1)))), break); v *= q; t *= q))); list); vecsort(Vec(f(1, 1, 2, k)));
T(n,k) = if(n < 2, return()); my(x=vecprod(primes(k)), y=2*x); while(1, my(v=fermat_psp(x, y, k, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);
print_table(n, k) = for(x=2, n, for(y=2, k, print1(T(x, y), ", ")); print(""));
for(k=2, 9, for(n=2, k, print1(T(n, k-n+2)", "))); \\ ~~~~

=cut

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMP    qw(:constant);

sub fermat_pseudoprimes ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $j) {

        my $s = rootint(divint($B, $m), $j);

        for (my $r ; $p <= $s ; $p = $r) {

            $r = next_prime($p);

            if ($base % $p == 0) {
                next;
            }

            my $z = znorder($base, $p);
            my $L = lcm($lambda, $z);

            gcd($L, $m) == '1' or next;

            for (my ($q, $v) = ($p+0, $m * $p) ; $v <= $B ; ($q, $v) = ($q*$p, $v*$p)) {

                my $z = znorder($base, $q);
                my $L = lcm($lambda, $z);

                gcd($L, $v) == 1 or last;

                if ($j == 1) {
                    $v >= $A or next;
                    $k == 1 and is_prime($v) and next;
                    ($v - 1) % $L == 0        or next;
                    $callback->($v);
                    next;
                }

                $v * $r <= $B or next;
                __SUB__->($v, $L, $r, $j - 1);

            }
        }
      }
      ->(1, 1, 2, $k);
}

#a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=fermat_psp(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

#~ T(n,k) = if(n < 2, return()); my(x=vecprod(primes(k)), y=2*x); while(1, my(v=fermat_psp(x, y, k, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);
#~ print_table(n, k) = for(x=2, n, for(y=2, k, print1(T(x, y), ", ")); print(""));
#~ for(k=2, 9, for(n=2, k, print1(T(n, k-n+2)", "))); \\ ~~~~

sub T($n, $k) {
    my $x = pn_primorial($k);
    my $y = 2*$x;

    $x = Math::GMP->new("$x");
    $y = Math::GMP->new("$y");

    for (;;) {
        my @arr;
        fermat_pseudoprimes($x, $y, $k, $n, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

my $count = 2;

for my $k (2..100) {
    for my $n (2..$k) {
        say $count++, " ", T($n, $k-$n+2);
    }
}

__END__

=for comment

# Square array A(n, k) read by antidiagonals downwards: smallest base-n Fermat pseudoprime with k distinct prime factors for k, n >= 2.
# https://oeis.org/A271873

# (VERSION 1)

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(z=znorder(Mod(base, q)), L=lcm(l, z)); if(gcd(L, m)==1, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%l == 0 && (v-1)%z == 0 && Mod(base, v)^(v-1) == 1, listput(list, v)), if(v*r <= B, list=concat(list, f(v, l, r, j-1)))); v *= q)))); list); vecsort(Vec(f(1, 1, 2, k)));
T(n,k) = if(n < 2, return()); my(x=vecprod(primes(k)), y=2*x); while(1, my(v=fermat_psp(x, y, k, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);
print_table(n, k) = for(x=2, n, for(y=2, k, print1(T(x, y), ", ")); print(""));
for(k=2, 9, for(n=2, k, print1(T(n, k-n+2)", "))); \\ ~~~~

# (VERSION 2)

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0, listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1)))), break); v *= q; t *= q))); list); vecsort(Vec(f(1, 1, 2, k)));
T(n,k) = if(n < 2, return()); my(x=vecprod(primes(k)), y=2*x); while(1, my(v=fermat_psp(x, y, k, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);
print_table(n, k) = for(x=2, n, for(y=2, k, print1(T(x, y), ", ")); print(""));
for(k=2, 9, for(n=2, k, print1(T(n, k-n+2)", "))); \\ ~~~~

# (VERSION 3) (faster)

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, lo, k) = my(list=List()); my(hi=sqrtnint(B\m, k)); if(lo > hi, return(list)); if(k==1, forstep(p=lift(1/Mod(m, l)), hi, l, if(isprimepower(p) && gcd(m*base, p) == 1, my(n=m*p); if(n >= A && (n-1) % znorder(Mod(base, p)) == 0, listput(list, n)))), forprime(p=lo, hi, base%p == 0 && next; my(z=znorder(Mod(base, p))); gcd(m,z) == 1 || next; my(q=p, v=m*p); while(v <= B, list=concat(list, f(v, lcm(l, z), p+1, k-1)); q *= p; Mod(base, q)^z == 1 || break; v *= p))); list); vecsort(Set(f(1, 1, 2, k)));
T(n,k) = if(n < 2, return()); my(x=vecprod(primes(k)), y=2*x); while(1, my(v=fermat_psp(x, y, k, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);
print_table(n, k) = for(x=2, n, for(y=2, k, print1(T(x, y), ", ")); print(""));
for(k=2, 9, for(n=2, k, print1(T(n, k-n+2)", "))); \\ ~~~~

# New terms:
#   341, 561, 91, 11305, 286, 15, 825265, 41041, 435, 124, 45593065, 825265, 11305, 561, 35, 370851481, 130027051, 418285, 41041, 1105, 6, 38504389105, 2531091745, 30534805, 2203201, 25585, 561, 21, 7550611589521, 38504389105, 370851481, 68800501, 682465, 62745, 105, 28

=cut

341, 561, 11305, 825265, 45593065, 370851481, 38504389105, 7550611589521, 277960972890601,
91, 286, 41041, 825265, 130027051, 2531091745, 38504389105, 5342216661145, 929845918823185,
15, 435, 11305, 418285, 30534805, 370851481, 38504389105, 7550611589521, 277960972890601,
124, 561, 41041, 2203201, 68800501, 979865601, 232250619601, 9746347772161, 1237707914764321,
35, 1105, 25585, 682465, 12306385, 305246305, 16648653385, 1387198666945, 75749848475665,
6, 561, 62745, 902785, 87570145, 9073150801, 211215631705, 24465723528961, 1135341818898001,
21, 105, 1365, 121485, 2103465, 96537441, 3958035081, 705095678001, 74398297074465,
28, 286, 2926, 421876, 5533066, 85851766, 15539169646, 2539184851126, 65749886703865,
33, 561, 41041, 1242241, 68800501, 4646703061, 216337302181, 9746347772161, 152064312120721,
