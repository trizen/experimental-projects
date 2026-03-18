#!/usr/bin/perl

# Least Carmichael number (A002997) that is the product of exactly n primes congruent to 3 modulo 4.
# https://oeis.org/A394179

# Known terms:
#   8911, 1773289, 1419339691, 4077957961, 3475350807391, 440515336876021, 574539328092938671, 2426698123549677901, 4971170854788923506051, 447301514144395660522501

=for comment

# PARI/GP program:

carmichael_3mod4(A, B, k) = A=max(A, vecprod(primes(k+1))\2); local f; (f = (m, l, lo, k) -> my(list=List()); my(hi=sqrtnint(B\m, k)); if(lo > hi, return(list)); if(k==1, lo=max(lo, ceil(A/m)); my(t=lift(1/Mod(m,l))); while(t < lo, t += l); forstep(p=t, hi, l, if(p%4 == 3 && (m*p-1) % (p-1) == 0 && isprime(p), listput(list, m*p))), forprime(p=lo, hi, if(p%4 == 3 && gcd(m, p-1) == 1, list=concat(list, f(m*p, lcm(l, p-1), p+1, k-1))))); list); vecsort(Vec(f(1, 1, 3, k)));
a(n) = if(n < 3, return()); my(x=1, y=2*x); while(1, my(v=carmichael_3mod4(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

# Lower-bounds:
#   a(14) > 79228162514264337593543950335
#   a(15) > 2535301200456458802993406410751
#   a(16) > 324518553658426726783156020576255

# New terms:
#   a(13) = 297982503152489384707421251

use 5.036;
use Math::GMPz;
use ntheory 0.74 qw(:all);

sub carmichael_numbers_3mod4_in_range ($A, $B, $k) {

    $A = vecmax($A, pn_primorial($k + 1) >> 1);

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

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

    my @list;

    sub ($m, $L, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        Math::GMPz::Rmpz_fits_ulong_p($u) || die "Too large value!";

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        $lo > $hi && return;

        if ($k == 1) {

            $hi = $max_p                      if ($max_p < $hi);
            $hi = Math::GMPz::Rmpz_get_ui($m) if (Math::GMPz::Rmpz_cmp_ui($m, $hi) < 0);
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

            my $inv_m = $t;
            $t += $L * cdivint($lo - $t, $L) if ($t < $lo);
            $t > $hi && return;

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if ($p % 4 == 3 and is_prime($p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                        my $term = Math::GMPz::Rmpz_init_set($v);
                        $B = $term if ($term < $B);
                        say "Found upper-bound: $term";
                        push @list, $term;
                    }
                }
            }

            return;
        }

        my $z   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $p % 4 == 3 or next;
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p >> 1) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p - 1);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p + 1, $k - 1);
        }
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), 3, $k);

    return sort { $a <=> $b } @list;
}

sub a($n) {

    say "Searching for a($n)";
    return if $n < 3;
    my $x = Math::GMPz->new("79228162514264337593543950335");
    my $y = (3*$x)>>1;

    while (1) {

        say "Sieving: [$x, $y]";
        my @list = carmichael_numbers_3mod4_in_range($x, $y, $n);
        if (@list) {
            say "Found: @list";
            return $list[0];
        }
        $x = $y+1;
        $y = (3*$x)>>1;
    }
}

say a(14);
