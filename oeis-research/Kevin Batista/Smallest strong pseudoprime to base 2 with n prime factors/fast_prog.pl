#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 24 September 2022
# https://github.com/trizen

# New terms found (24 September 2022):
#   a(11) = 24325630440506854886701
#   a(12) = 27146803388402594456683201
#   a(13) = 4365221464536367089854499301
#   a(14) = 2162223198751674481689868383601
#   a(15) = 548097717006566233800428685318301

=for comment

PARI/GP program:

strong_fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j, k_exp, congr) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0, listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1, k_exp, congr)))), break); v *= q; t *= q)))); list); my(res=f(1, 1, 2, k, 0, 1)); for(v=0, logint(B, 2), res=concat(res, f(1, 1, 2, k, v, -1))); vecsort(Vec(res));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=strong_fermat_psp(x, y, n, 2)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMPz;

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = ($x / $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub squarefree_strong_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, Math::GMPz->new(pn_primorial($k)));

    $A > $B and return;

    my $generator = sub ($m, $lambda, $p, $k, $k_exp, $congr, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                my $valuation = valuation($_ - 1, 2);
                if ($valuation > $k_exp and powmod($base, (($_ - 1) >> $valuation) << $k_exp, $_) == ($congr % $_)) {
                    my $t = $m * $_;
                    if (Math::GMPz::Rmpz_divisible_ui_p($t - 1, $lambda) and Math::GMPz::Rmpz_divisible_ui_p($t - 1, znorder($base, $_))) {
                        say "# Found: $t";
                        $callback->($t);
                        $B = $t if ($t < $B);
                    }
                }
            } $u, $v;

            return;
        }

        my $s = rootint(($B / $m), $k);

        for (my $r ; $p <= $s ; $p = $r) {

            $r = next_prime($p);
            $base % $p == 0 and next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                    or next;
            powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

            my $z = znorder($base, $p);
            my $L = lcm($lambda, $z);

            gcd($L, $m) == 1 or next;

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = ($B / $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, $k_exp, $congr, (($k == 2 && $r > $u) ? $r : $u), $v);
            }
        }
    };

    say "# Sieving range: [$A, $B]";

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), 1, 2, $k, 0, 1);

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (0 .. logint($B, 2)) {
        say "# Generating with v = $v";
        $generator->(Math::GMPz->new(1), 1, 2, $k, $v, -1);
    }
}

my $k = 10;

my $from = Math::GMPz->new(2);
my $upto = Math::GMPz->new(pn_primorial($k));

while (1) {

    my @found;
    squarefree_strong_fermat_pseudoprimes_in_range($from, $upto, $k, 2, sub ($n) { push @found, $n });

    if (@found) {
        @found = sort {$a <=> $b} @found;
        say "Terms: @found";
        say "a($k) = $found[0]";
        last;
    }

    $from = $upto+1;
    $upto = 2*$from;
}
