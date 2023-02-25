#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.020;
use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMP    qw(:constant);

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = $x / $y;
    ($q * $y == $x) ? $q : ($q + 1);
}

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    #my $max_p = 313897;
    my $max_p = 1e6;

    #my $m = "1056687375767188465946114009917285";
    #my $m = Math::GMP->new("6863588485053268178811679453193455");
    my $m = Math::GMP->new("1049092636351906987863186392741166403295");
    #my $m = Math::GMP->new("8035018770721572330061486952496026236686375478339885");
    #my $m = Math::GMP->new("288796538380586656981514139972529852735632478655");
    #my $m = Math::GMP->new("1127872835696879363649741868028740611132217832559978865049182075837136570515");

    my $L = lcm(map { $_ - 1 } factor($m));

    if ($L == 0) {
        $L = 1;
    }

    $A = $A * $m;
    $B = $B * $m;

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMP->new("$A");
    $B = Math::GMP->new("$B");

    if ($B > Math::GMP->new("2059832906607460252767290568443059994787898033540634712711845135488141590979778401392385")) {
        $B = Math::GMP->new("2059832906607460252767290568443059994787898033540634712711845135488141590979778401392385");
    }

    if ($A > $B) {
        return;
    }

    sub ($m, $L, $lo, $k) {

        my $hi = rootint($B/$m, $k);
        $hi = vecmin($max_p, $hi);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            $lo = vecmax($lo, divceil($A, $m));
            $lo > $hi && return;

            my $t = invmod($m, $L);
            $t > $hi && return;
            $t += $L while ($t < $lo);

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if (is_prime($p)) {
                    my $n = $m*$p;
                    if (($n-1) % ($p-1) == 0) {
                        $callback->($n);
                    }
                }
            }

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {

            if ($m % $p == 0) {
                next;
            }

            gcd($m, $p-1) == 1 or next;
            is_smooth($p-1, 41) || next;

            __SUB__->($m*$p, lcm($L, $p - 1), $p+1, $k-1);
        }
      }
      ->($m, $L, 3, $k);

    return 1;
}

my $from = 2;
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
