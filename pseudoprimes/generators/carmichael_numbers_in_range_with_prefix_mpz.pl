#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    #my $max_p = 313897;
    my $max_p = 1e6;

    #my $m = "1056687375767188465946114009917285";
    #my $m = Math::GMPz->new("6863588485053268178811679453193455");
    my $m = Math::GMPz->new("1049092636351906987863186392741166403295");
    #my $m = Math::GMPz->new("8035018770721572330061486952496026236686375478339885");
    #my $m = Math::GMPz->new("288796538380586656981514139972529852735632478655");
    #my $m = Math::GMPz->new("1127872835696879363649741868028740611132217832559978865049182075837136570515");

    my $L = lcm(map { $_ - 1 } factor($m));

    if ($L == 0) {
        $L = 1;
    }

    $L = Math::GMPz->new("$L");

    $A = $A * $m;
    $B = $B * $m;

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    if ($B > Math::GMPz->new("2059832906607460252767290568443059994787898033540634712711845135488141590979778401392385")) {
        $B = Math::GMPz->new("2059832906607460252767290568443059994787898033540634712711845135488141590979778401392385");
    }

    $A = vecmax($A, pn_primorial($k + 1) >> 1);

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    if ($A > $B) {
        return;
    }

    sub ($m, $L, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);
        $hi = vecmin($max_p, $hi);

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

            Math::GMPz::Rmpz_invert($v, $m, $L) || return;

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
                if (is_prime($p) and !Math::GMPz::Rmpz_divisible_ui_p($m, $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                    }
                }
            }

            return;
        }

        my $z   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            Math::GMPz::Rmpz_divisible_ui_p($m, $p) and next;
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p - 1) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p - 1);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p + 1, $k - 1);
        }
      }
      ->($m, $L, 5, $k);

    return 1;
}

my $from = Math::GMPz->new(2);
my $upto = 2 * $from;

while (1) {

    my $ok = 0;
    say "# Range: ($from, $upto)";

    foreach my $k (10 .. 100) {
        carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n }) or next;
        $ok = 1;
    }

    $ok || last;

    $from = $upto + 1;
    $upto = 2 * $from;
}
