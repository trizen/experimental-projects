#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 24 September 2022
# https://github.com/trizen

# Carmichael numbers which are also base-2 strong pseudoprimes.
# https://oeis.org/A063847

# Let a(n) be the smallest Carmichael number with n prime factors that is also a strong pseudoprime to base 2.

# First few terms:
#   15841, 5310721, 440707345, 10761055201, 5478598723585, 713808066913201, 1022751992545146865, 5993318051893040401

# New terms found (24 September 2022):
#   a(11) = 120459489697022624089201
#   a(12) = 27146803388402594456683201

# New terms: (1st October 2022):
#   a(13) = 14889929431153115006659489681

# Lower-bounds:
#   a(13) > 10^28.
#   a(13) > 10704854480066618540513296383.

# Finding a(13) took 1 hour and 34 minutes.

=for comment

# PARI/GP programs:

# Version 1 (slower)
carmichael_strong_psp(A, B, k, base) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, k_exp, congr, u=0, v=0) = my(list=List()); if(k==1, forprime(q=u, v, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, my(t=m*q); if((t-1)%l == 0 && (t-1)%(q-1) == 0, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), if(base%q != 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, my(t = m*q); my(L=lcm(l, q-1)); if(gcd(L, t) == 1, my(u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, k_exp, congr, u, v)))))))); list); my(res=f(1, 1, 3, k, 0, 1)); for(v=0, logint(B, 2), res=concat(res, f(1, 1, 3, k, v, -1))); vecsort(Vec(res));
a(n,base=2) = if(n < 3, return()); my(x=vecprod(primes(n+1))\2,y=2*x); while(1, my(v=carmichael_strong_psp(x,y,n,base)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Version 2 (faster)
carmichael_strong_psp(A, B, k, base) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, k_exp, congr, u=0, v=0) = my(list=List()); if(k==1, forprime(q=u, v, my(t=m*q); if((t-1)%l == 0 && (t-1)%(q-1) == 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), if(base%q != 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, my(L=lcm(l, q-1)); if(gcd(L, m) == 1, my(t = m*q, u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, k_exp, congr, u, v)))))))); list); my(res=f(1, 1, 3, k, 0, 1)); for(v=0, logint(B, 2), res=concat(res, f(1, 1, 3, k, v, -1))); vecsort(Vec(res));
a(n,base=2) = if(n < 3, return()); my(x=vecprod(primes(n+1))\2,y=2*x); while(1, my(v=carmichael_strong_psp(x,y,n,base)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

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

sub strong_carmichael_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, Math::GMPz->new(pn_primorial($k)));

    $A > $B and return;

    my $generator = sub ($m, $lambda, $p, $k, $k_exp, $congr, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                my $valuation = valuation($_ - 1, 2);
                if ($valuation > $k_exp and powmod($base, (($_ - 1) >> $valuation) << $k_exp, $_) == ($congr % $_)) {
                    my $t = $m * $_;
                    if (Math::GMPz::Rmpz_divisible_ui_p($t - 1, $lambda) and Math::GMPz::Rmpz_divisible_ui_p($t - 1, $_-1)) {
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

            my $L = lcm($lambda, $p-1);
            gcd($L, $m) == 1 or next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                    or next;
            powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

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

my $k = 13;

my $from = Math::GMPz->new(2);
my $upto = Math::GMPz->new(pn_primorial($k));

while (1) {

    my @found;
    strong_carmichael_in_range($from, $upto, $k, 2, sub ($n) { push @found, $n });

    if (@found) {
        @found = sort {$a <=> $b} @found;
        say "Terms: @found";
        say "a($k) = $found[0]";
        last;
    }

    $from = $upto+1;
    $upto = 3*$from;
}

__END__
a(3)  = 15841
a(4)  = 5310721
a(5)  = 440707345
a(6)  = 10761055201
a(7)  = 5478598723585
a(8)  = 713808066913201
a(9)  = 1022751992545146865
a(10) = 5993318051893040401
a(11) = 120459489697022624089201
a(12) = 27146803388402594456683201
