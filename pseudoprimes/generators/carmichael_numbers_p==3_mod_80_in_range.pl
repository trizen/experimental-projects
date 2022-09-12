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
#~ use Math::GMP    qw(:constant);
use Math::GMPz;

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = divint($x, $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    #my $max_p = 313897;
    #my $max_p = 10000;

    #my $m = "1056687375767188465946114009917285";
    #my $m = Math::GMPz->new("6863588485053268178811679453193455");
    my $m = 1;
    my $L = lcm(map { $_ - 1 } factor($m));

    if ($L == 0) {
        $L = 1;
    }

    $A = $A * $m;
    $B = $B * $m;

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    #$B = vecmin($B, 330468624532072027);

    #~ if ($A > $B) {
        #~ return;
    #~ }

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            say "# Sieving: $m -> ($u, $v)" if ($v - $u > 1e7);

            if (($v - $u)/80 > 1e10) {
                die "Range too large!\n";
            }

            for(my $x = divceil($u, 80)*80; $x <= $v; $x += 80) {
                my $p = $x+3;
                if (is_prime($p)) {
                    my $t = $m * $p;
                    if (($t - 1) % $lambda == 0 and ($t - 1) % ($p - 1) == 0) {
                        $callback->($t);
                    }
                }
            }

            return;
        }

        my $s = rootint(($B / $m), $k);

        for(my $q = divceil($p, 80)*80; $q <= $s; $q += 80) {

            my $p = $q+3;
            $p < 1e7 and next;
            is_prime($p) || next;

            if ($m % $p == 0) {
                next;
            }

            my $L = lcm($lambda, $p - 1);
            gcd($L, $m) == 1 or next;

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = ($B / $t);

            if ($u <= $v) {
                my $r = next_prime(14*$p);
                __SUB__->($t, $L, $r, $k - 1, (($k == 2 && $r > $u) ? $r : $u), $v);
            }
        }
      }
      ->(Math::GMPz->new($m), $L, 3, $k);

    return 1;
}

my $from = Math::GMPz->new(2)**64;
my $upto = 2 * $from;

while (1) {

    say "# Range: ($from, $upto)";

    foreach my $k (3) {
        carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });
    }

    $from = $upto + 1;
    $upto = 2 * $from;
}
