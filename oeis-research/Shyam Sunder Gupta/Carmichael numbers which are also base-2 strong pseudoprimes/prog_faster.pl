#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 05 March 2023
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [A,B] that are also strong Fermat pseudoprimes to a given base. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

=for comment

# PARI/GP program:

carmichael_strong_psp(A, B, k, base) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, k_exp, congr, u=0, v=0) = my(list=List()); if(k==1, forprime(q=u, v, my(t=m*q); if((t-1)%l == 0 && (t-1)%(q-1) == 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), if(base%q != 0, my(tv=valuation(q-1, 2)); if(tv > k_exp && Mod(base, q)^(((q-1)>>tv)<<k_exp) == congr, my(L=lcm(l, q-1)); if(gcd(L, m) == 1, my(t = m*q, u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, k_exp, congr, u, v)))))))); list); my(res=f(1, 1, 3, k, 0, 1)); for(v=0, logint(B, 2), res=concat(res, f(1, 1, 3, k, v, -1))); vecsort(Vec(res));

=cut

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

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub strong_carmichael_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, Math::GMPz->new(pn_primorial($k)));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    $A > $B and return;

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    # max_p = floor((1 + sqrt(8*B + 1))/4)
    my $max_p = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_mul_2exp($max_p, $B, 3);
    Math::GMPz::Rmpz_add_ui($max_p, $max_p, 1);
    Math::GMPz::Rmpz_sqrt($max_p, $max_p);
    Math::GMPz::Rmpz_add_ui($max_p, $max_p, 1);
    Math::GMPz::Rmpz_div_2exp($max_p, $max_p, 2);
    $max_p = Math::GMPz::Rmpz_get_ui($max_p) if Math::GMPz::Rmpz_fits_ulong_p($max_p);

    my $generator = sub ($m, $L, $lo, $k, $k_exp, $congr) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        Math::GMPz::Rmpz_fits_ulong_p($u) || die "Too large value!";

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($k == 1 and $max_p < $hi) {
            $hi = $max_p;
        }

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            Math::GMPz::Rmpz_cdiv_q($u, $A, $m);

            if (Math::GMPz::Rmpz_fits_ulong_p($u)) {
                $lo = vecmax($lo, Math::GMPz::Rmpz_get_ui($u));
            }
            elsif (Math::GMPz::Rmpz_cmp_ui($u, $lo) > 0) {
                if (Math::GMPz::Rmpz_cmp_ui($u, $hi) > 0) {
                    return;
                }
                $lo = Math::GMPz::Rmpz_get_ui($u);
            }

            if ($lo > $hi) {
                return;
            }

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
                if (is_prime($p)) {
                    my $valuation = valuation($p - 1, 2);
                    if ($valuation > $k_exp and powmod($base, ($p - 1) >> ($valuation - $k_exp), $p) == ($congr % $p)) {
                        Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                            my $term = Math::GMPz::Rmpz_init_set($v);
                         say "# Found upper-bound: $term";
                         $B = $term if ($term < $B);
                         $callback->($term);
                        }
                    }
                }
            }

            return;
        }

        my $z   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p - 1) == 1 or next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                   or next;
            powmod($base, ($p - 1) >> ($valuation - $k_exp), $p) == ($congr % $p) or next;

            Math::GMPz::Rmpz_mul_ui($z, $m, $p);
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p - 1);

            __SUB__->($z, $lcm, $p + 1, $k - 1, $k_exp, $congr);
        }
    };

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (reverse(0 .. logint($B, 2))) {
        $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, $v, -1);
    }

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, 0, 1);
}

my $k = 11;

my $from = Math::GMPz->new(2);
my $upto = Math::GMPz->new(pn_primorial($k));

while (1) {

    say "# Sieving range: [$from, $upto]";

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
a(13) = 14889929431153115006659489681
