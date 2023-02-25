#!/usr/bin/perl

# Number of eleven-prime Carmichael numbers less than 10^n.
# https://oeis.org/A299711

# Known terms:
#   1, 49, 576, 5804, 42764

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub count_carmichael_numbers_in_range ($A, $B, $k) {

    $A = vecmax($A, pn_primorial($k + 1) >> 1);

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();


    sub ($m, $L, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return 0;
        }

        if ($k == 1) {

            Math::GMPz::Rmpz_cdiv_q($u, $A, $m);

            if (Math::GMPz::Rmpz_fits_ulong_p($u)) {
                $lo = vecmax($lo, Math::GMPz::Rmpz_get_ui($u));
            }
            elsif (Math::GMPz::Rmpz_cmp_ui($u, $lo) > 0) {
                if (Math::GMPz::Rmpz_cmp_ui($u, $hi) > 0) {
                    return 0;
                }
                $lo = Math::GMPz::Rmpz_get_ui($u);
            }

            if ($lo > $hi) {
                return 0;
            }

            Math::GMPz::Rmpz_invert($v, $m, $L);

            if (Math::GMPz::Rmpz_fits_ulong_p($L)) {
                $L = Math::GMPz::Rmpz_get_ui($L);
            }

            my $t = Math::GMPz::Rmpz_get_ui($v);
            $t > $hi && return 0;
            $t += $L while ($t < $lo);

            my $count = 0;

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if (is_prime($p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p - 1)) {
                       ++$count;
                    }
                }
            }

            return $count;
        }

        my $count = 0;
        my $z = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p-1) == 1 or next;
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p-1);
            $count += __SUB__->($z, $lcm, $p + 1, $k - 1);
        }

        return $count;
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), 3, $k);
}

my $k = 11;
my $total = 0;

foreach my $n (17..100) {
    $total += count_carmichael_numbers_in_range(powint(10, $n-1), powint(10, $n), $k);
    say "a($n) = ", $total;
}

__END__
a(17) = 1
a(18) = 49
a(19) = 576
a(20) = 5804
