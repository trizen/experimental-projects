#!/usr/bin/perl

# Smallest base-n Fermat pseudoprime with n distinct prime factors.
# https://oeis.org/A271874

# Known terms:
#   341, 286, 11305, 2203201, 12306385

# New terms:
#   341, 286, 11305, 2203201, 12306385, 9073150801, 3958035081, 2539184851126, 152064312120721, 10963650080564545, 378958695265110961, 1035551157050957605345, 57044715596229144811105, 6149883077429715389052001, 426634466310819456228926101, 166532358913107245358261399361

# a(7)-a(17) from ~~~~

# New terms found:
#   a(7)  = 9073150801
#   a(8)  = 3958035081
#   a(9)  = 2539184851126
#   a(10) = 152064312120721
#   a(11) = 10963650080564545
#   a(12) = 378958695265110961
#   a(13) = 1035551157050957605345
#   a(14) = 57044715596229144811105
#   a(15) = 6149883077429715389052001
#   a(16) = 426634466310819456228926101
#   a(17) = 166532358913107245358261399361
#   a(18) = 15417816366043964846263074467761
#   a(19) = 7512467783390668787701493308514401
#   a(20) = 182551639864089765855891394794831841
#   a(21) = 73646340445282784237405289363506168161
#   a(22) = 12758106140074522771498516740500829830401
#   a(23) = 233342982005748265084053300837644203002001
#   a(24) = 41711804619389959984296019492852898455016161
#   a(25) = 35654496932132728635037829367481372591614792001
#   a(26) = 13513093081489380840188651246675032067011140079201
#   a(27) = 2758048007075525871042090011995729226316189827518801

=for comment

# PARI/GP program:

fermat_psp(A, B, k, base=2) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(z=znorder(Mod(base, q)), L=lcm(l, z)); if(gcd(L, m)==1, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%l == 0 && (v-1)%z == 0 && Mod(base, v)^(v-1) == 1, listput(list, v)), if(v*r <= B, list=concat(list, f(v, l, r, j-1)))); v *= q)))); list); vecsort(Vec(f(1, 1, 2, k)));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=fermat_psp(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

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

            gcd($L, $m) == 1 or next;

            for (my $v = $m * $p ; $v <= $B ; $v *= $p) {

                if ($j == 1) {
                    $v >= $A or next;
                    $k == 1 and is_prime($v) and next;
                    ($v - 1) % $lambda == 0        or next;
                    ($v - 1) % $z == 0             or next;
                    powmod($base, $v - 1, $v) == 1 or next;
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

sub a($n) {
    my $x = pn_primorial($n);
    my $y = 2*$x;

    $x = Math::GMP->new("$x");
    $y = Math::GMP->new("$y");

    for (;;) {
        my @arr;
        fermat_pseudoprimes($x, $y, $n, $n, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n(2..100) {
    say "a($n) = ", a($n);
}

__END__

=for comment

# Square array A(n, k) read by antidiagonals downwards: smallest base-n Fermat pseudoprime with k distinct prime factors for k, n >= 2.
# https://oeis.org/A271873

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(z=znorder(Mod(base, q)), L=lcm(l, z)); if(gcd(L, m)==1, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%l == 0 && (v-1)%z == 0 && Mod(base, v)^(v-1) == 1, listput(list, v)), if(v*r <= B, list=concat(list, f(v, l, r, j-1)))); v *= q)))); list); vecsort(Vec(f(1, 1, 2, k)));
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
