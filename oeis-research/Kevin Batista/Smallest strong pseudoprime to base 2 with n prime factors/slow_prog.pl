#!/usr/bin/perl

# Smallest strong pseudoprime to base 2 with n prime factors
# https://oeis.org/A180065

# Known terms:
#   2047, 15841, 800605, 293609485, 10761055201, 5478598723585, 713808066913201, 90614118359482705, 5993318051893040401

=for comment

# PARI/GP program:

is_strong_psp(n, a=2)={ (bittest(n, 0) && !isprime(n) && n>8) || return; my(s=valuation(n-1, 2)); if(1==a=Mod(a, n)^(n>>s), return(1)); while(a!=-1 && s--, a=a^2); a==-1}; \\ A001262
strong_fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0 && is_strong_psp(v, base), listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1)))), break); v *= q; t *= q))); list); vecsort(Vec(f(1, 1, 2, k)));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=strong_fermat_psp(x, y, n, 2)); if(#v >= 1, return(v[1])); x=y+1; y=2*x);

=cut

# Very hard to compute more terms...

=for comment

# Some upper-bounds:

a(11) <= 40458813831093914176528685701
a(12) <= 3461315300911389965986555018529761
a(13) <= 1793888484612948579347804219906251
a(14) <= 11204126171093532395238176008628640001
a(15) <= 52763042375348388525807775606810431553349251
a(16) <= 8490206016886862443343349923062834577705405389801
a(17) <= 16466175808047026414728161638977648257386104008228485611
a(18) <= 5344281976789774350298352596501700430295430104885257558315750001
a(27) <= 7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109251

=cut

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                my $t = $m*$_;
                if (($t-1)%$lambda == 0 and is_strong_pseudoprime($t, $base) and ($t-1)%znorder($base, $_) == 0) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for(my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);
            $base % $p == 0 and next;

            my $z = znorder($base, $p);
            my $L = lcm($lambda, $z);

            gcd($L, $m) == 1 or next;

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(1, 1, 2, $k);
}

sub a($n) {
    my $x = pn_primorial($n);
    my $y = 2*$x;

    #$x = Math::GMP->new("$x");
    #$y = Math::GMP->new("$y");

    for (;;) {
        my @arr;
        fermat_pseudoprimes_in_range($x, $y, $n, 2, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (2..100) {
    say "a($n) = ", a($n);
}

__END__
a(2) = 2047
a(3) = 15841
a(4) = 800605
a(5) = 293609485
a(6) = 10761055201
a(7) = 5478598723585
