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

# New terms found (05 March 2023):
#

# Lower-bounds:
#   a(28) > 176360023908895562533264343617898477570417021635526655

# Upper-bounds:
#   a(28) <= 1320340354477450170682291329830138947225695029536281601

=for comment

# PARI/GP program (slow):

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0, listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1)))), break); v *= q; t *= q))); list); vecsort(Vec(f(1, 1, 2, k)));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=fermat_psp(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# PARI/GP program (fast):

fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, lo, k) = my(list=List()); my(hi=sqrtnint(B\m, k)); if(lo > hi, return(list)); if(k==1, forstep(p=lift(1/Mod(m, l)), hi, l, if(isprimepower(p) && gcd(m*base, p) == 1, my(n=m*p); if(n >= A && (n-1) % znorder(Mod(base, p)) == 0, listput(list, n)))), forprime(p=lo, hi, base%p == 0 && next; my(z=znorder(Mod(base, p))); gcd(m,z) == 1 || next; my(q=p, v=m*p); while(v <= B, list=concat(list, f(v, lcm(l, z), p+1, k-1)); q *= p; Mod(base, q)^z == 1 || break; v *= p))); list); vecsort(Set(f(1, 1, 2, k)));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=fermat_psp(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut


use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my %seen;

    sub ($m, $L, $lo, $j) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        if ($j == 1) {

            Math::GMPz::Rmpz_invert($v, $m, $L);

            if (Math::GMPz::Rmpz_cmp_ui($v, $hi) > 0) {
                return;
            }

            if (Math::GMPz::Rmpz_fits_ulong_p($L)) {
                $L = Math::GMPz::Rmpz_get_ui($L);
            }

            my $t = Math::GMPz::Rmpz_get_ui($v);
            $t > $hi && return;
            $t += $L while ($t < $lo);

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if (is_prime_power($p) and Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p) == 1 and gcd($base, $p) == 1) {

                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);

                    if ($k == 1 and is_prime($p) and Math::GMPz::Rmpz_cmp_ui($m, 1) == 0) {
                        ## ok
                    }
                    elsif (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, znorder($base, $p))) {
                            if (!$seen{Math::GMPz::Rmpz_get_str($v, 10)}++) {
                                my $value = Math::GMPz::Rmpz_init_set($v);
                                $B = $value if ($value < $B);
                                say "Found upper-bound: $value";
                                $callback->($value);
                            }
                        }
                    }
                }
            }

            return;
        }

        my $u   = Math::GMPz::Rmpz_init();
        my $v   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;

            my $z = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);

            Math::GMPz::Rmpz_set_ui($u, $p);

            for (Math::GMPz::Rmpz_mul_ui($v, $m, $p) ;
                 Math::GMPz::Rmpz_cmp($v, $B) <= 0 ;
                 Math::GMPz::Rmpz_mul_ui($v, $v, $p)) {
                __SUB__->($v, $lcm, $p + 1, $j - 1);
                Math::GMPz::Rmpz_mul_ui($u, $u, $p);
                powmod($base, $z, $u) == 1 or last;
            }
        }
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    say "Searching for a($n)";

    my $x = pn_primorial($n);
    my $y = 2*$x;

    $x = Math::GMPz->new("$x");
    $y = Math::GMPz->new("$y");

    for (;;) {
        say "Sieving range: [$x, $y]";
        my @arr;
        fermat_pseudoprimes_in_range($x, $y, $n, $n, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (20) {
    say "a($n) = ", a($n);
}
