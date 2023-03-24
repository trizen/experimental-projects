#!/usr/bin/perl

# Smallest base-n strong Fermat pseudoprime with n distinct prime factors.
# https://oeis.org/A271874

# Known terms:
#   2047, 8911, 129921, 381347461, 333515107081, 37388680793101, 713808066913201, 665242007427361, 179042026797485691841, 8915864307267517099501, 331537694571170093744101, 2359851544225139066759651401, 17890806687914532842449765082011

=for comment

# PARI/GP program:

strong_check(p, base, e, r) = my(tv=valuation(p-1, 2)); tv > e && Mod(base, p)^((p-1)>>(tv-e)) == r;
strong_fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, lo, k, e, r) = my(list=List()); my(hi=sqrtnint(B\m, k)); if(lo > hi, return(list)); if(k==1, forstep(p=lift(1/Mod(m, l)), hi, l, if(isprimepower(p) && gcd(m*base, p) == 1 && strong_check(p, base, e, r), my(n=m*p); if(n >= A && (n-1) % znorder(Mod(base, p)) == 0, listput(list, n)))), forprime(p=lo, hi, base%p == 0 && next; strong_check(p, base, e, r) || next; my(z=znorder(Mod(base, p))); gcd(m,z) == 1 || next; my(q=p, v=m*p); while(v <= B, list=concat(list, f(v, lcm(l, z), p+1, k-1, e, r)); q *= p; Mod(base, q)^z == 1 || break; v *= p))); list); my(res=f(1, 1, 2, k, 0, 1)); for(v=0, logint(B, 2), res=concat(res, f(1, 1, 2, k, v, -1))); vecsort(Set(res));
a(n) = if(n < 2, return()); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=strong_fermat_psp(x, y, n, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

# It takes 25 minutes to find the terms a(2)-a(13).

# Lower-bounds:
#   a(14) > 12428336051357263377401993232370

# Upper-bounds:
#   a(14) <= 17890806687914532842449765082011

# It took 8 hours to find a(14).

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub strong_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my %seen;

    my $generator = sub ($m, $L, $lo, $j, $k_exp, $congr) {

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

                    my $val = valuation($p - 1, 2);
                    $val > $k_exp                                                   or next;
                    powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p) or next;

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

            my $val = valuation($p - 1, 2);
            $val > $k_exp                                                   or next;
            powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p) or next;

            my $z = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);

            Math::GMPz::Rmpz_set_ui($u, $p);

            for (Math::GMPz::Rmpz_mul_ui($v, $m, $p) ;
                 Math::GMPz::Rmpz_cmp($v, $B) <= 0 ;
                 Math::GMPz::Rmpz_mul_ui($v, $v, $p)) {
                __SUB__->($v, $lcm, $p + 1, $j - 1, $k_exp, $congr);
                Math::GMPz::Rmpz_mul_ui($u, $u, $p);
                powmod($base, $z, $u) == 1 or last;
            }
        }
    };

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, 0, 1);

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (reverse(0 .. logint($B, 2))) {
        $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, $v, -1);
    }
}

sub a($n) {

    say "Searching for a($n)";

    my $x = pn_primorial($n);
    my $y = 2*$x;

    #$x = Math::GMPz->new("12428336051357263377401993232370");
    #$y = Math::GMPz->new("17890806687914532842449765082011");

    $x = Math::GMPz->new("$x");
    $y = Math::GMPz->new("$y");

    for (;;) {
        say "Sieving range: [$x, $y]";
        my @arr;
        strong_fermat_pseudoprimes_in_range($x, $y, $n, $n, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (10) {
    say "a($n) = ", a($n);
}

__END__
a(2) = 2047
a(3) = 8911
a(4) = 129921
a(5) = 381347461
a(6) = 333515107081
a(7) = 37388680793101
a(8) = 713808066913201
a(9) = 665242007427361
a(10) = 179042026797485691841
a(11) = 8915864307267517099501
a(12) = 331537694571170093744101
a(13) = 2359851544225139066759651401
a(14) = 17890806687914532842449765082011
