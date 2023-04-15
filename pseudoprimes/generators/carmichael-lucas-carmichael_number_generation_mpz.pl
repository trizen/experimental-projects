#!/usr/bin/perl

# Conjecture:
#   Letting this program run long enough, it will find a Carmichael number that is also a Lucas-Carmichael number.

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    my $max_prime  = ~0;
    my $max_lambda = 1e9;

    my $m = Math::GMPz->new("1");

    my $L1 = lcm(map { $_ - 1 } factor($m));
    my $L2 = lcm(map { $_ + 1 } factor($m));

    if ($L1 == 0) {
        $L1 = 1;
    }

    if ($L2 == 0) {
        $L2 = 1;
    }

    $L1 = Math::GMPz->new("$L1");
    $L2 = Math::GMPz->new("$L2");

    $A = $A * $m;
    $B = $B * $m;

    $A = vecmax($A, pn_primorial($k + 1) >> 1);

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    if ($A > $B) {
        return;
    }

    sub ($m, $L1, $L2, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);
        $hi = vecmin($max_prime, $hi);

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

            Math::GMPz::Rmpz_invert($v, $m, $L1) || return;

            if (Math::GMPz::Rmpz_cmp_ui($v, $hi) > 0) {
                return;
            }

            my $x = Math::GMPz::Rmpz_get_ui($v);

            Math::GMPz::Rmpz_invert($v, $m, $L2) || return;
            Math::GMPz::Rmpz_sub($v, $L2, $v);

            if (Math::GMPz::Rmpz_cmp_ui($v, $hi) > 0) {
                return;
            }

            my $y = Math::GMPz::Rmpz_get_ui($v);

            if (Math::GMPz::Rmpz_fits_ulong_p($L1)) {
                $L1 = Math::GMPz::Rmpz_get_ui($L1);
            }

            if (Math::GMPz::Rmpz_fits_ulong_p($L2)) {
                $L2 = Math::GMPz::Rmpz_get_ui($L2);
            }

            my $t = chinese([$x, $L1], [$y, $L2]) || return;
            $t > $hi && return;

            #$t += $L2 while ($t < $lo);

            say "# Checking t = $t with [$L1, $L2] and m = $m";

            my $L3 = lcm($L1, $L2);

            for (my $p = $t ; $p <= $hi ; $p += $L3) {
                if (is_prime($p) and !Math::GMPz::Rmpz_divisible_ui_p($m, $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_add_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p + 1)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                            die "Found counter-example: $v";
                            $callback->(Math::GMPz::Rmpz_init_set($v));
                        }
                    }
                }
            }

            return;

            for (my $p = $t ; $p <= $hi ; $p += $L1) {
                if (is_prime($p) and !Math::GMPz::Rmpz_divisible_ui_p($m, $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                        Math::GMPz::Rmpz_add_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, $p + 1)) {
                            die "Found counter-example: $v";
                            $callback->(Math::GMPz::Rmpz_init_set($v));
                        }
                    }
                }
            }

            for (my $p = $t ; $p <= $hi ; $p += $L2) {
                if (is_prime($p) and !Math::GMPz::Rmpz_divisible_ui_p($m, $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_add_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p + 1)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                            die "Found counter-example: $v";
                            $callback->(Math::GMPz::Rmpz_init_set($v));
                        }
                    }
                }
            }

            return;
        }

        my $z    = Math::GMPz::Rmpz_init();
        my $lcm1 = Math::GMPz::Rmpz_init();
        my $lcm2 = Math::GMPz::Rmpz_init();

        my @primes = @{primes($lo, $hi)};

        foreach my $congr (1, 3, 5, 7, 11) {

            foreach my $p (@primes) {

                $p % 12 == $congr        or next;   # prime factors must be congruent to each other modulo 12
                gcd($p - 1, $p + 1) == 2 or next;

                Math::GMPz::Rmpz_divisible_ui_p($m, $p) and next;

                #is_smooth(($p-1)*($p+1), 13) || next;

                # All prime factors p must satisfy: (p^2 - 1)/2 == 0 (mod 12)
                modint(divint(subint(mulint($p, $p), 1), 2), 12) == 0 or next;

                Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p - 1) == 1 or next;
                Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p + 1) == 1 or next;

                Math::GMPz::Rmpz_lcm_ui($lcm1, $L1, $p - 1);
                Math::GMPz::Rmpz_lcm_ui($lcm2, $L2, $p + 1);

                Math::GMPz::Rmpz_gcd($z, $lcm1, $lcm2);
                Math::GMPz::Rmpz_cmp_ui($z, 2) == 0 or next;

                #Math::GMPz::Rmpz_fits_ulong_p($lcm) || next;
                #Math::GMPz::Rmpz_fits_ulong_p($lcm2) || next;

                Math::GMPz::Rmpz_cmp_ui($lcm1, $max_lambda) <= 0 or next;
                Math::GMPz::Rmpz_cmp_ui($lcm2, $max_lambda) <= 0 or next;

                Math::GMPz::Rmpz_lcm($z, $lcm1, $lcm2);
                Math::GMPz::Rmpz_cmp_ui($z, $max_prime) <= 0 or next;

                #Math::GMPz::Rmpz_cmp_ui($lcm, 1e4) < 0 or next;
                Math::GMPz::Rmpz_mul_ui($z, $m, $p);

                __SUB__->($z, $lcm1, $lcm2, $p + 1, $k - 1);
            }
        }
      }
      ->($m, $L1, $L2, 3, $k);

    return 1;
}

my $from = Math::GMPz->new(2)**68;

#my $upto = Math::GMPz->new("713211736645623197793013755552001");
my $upto = 10 * $from;

while (1) {

    my $ok = 0;
    say "# Range: ($from, $upto)";

    foreach my $k (5 .. 100) {
        $k % 2 == 1 or next;
        #$k % 2 == 0 or next;
        carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n }) or next;
        $ok = 1;
    }

    $ok || last;

    $from = $upto + 1;
    $upto = 10 * $from;
}
