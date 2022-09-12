#!/usr/bin/perl

# Method for finding the smallest Lucas-Carmichael number divisible by n.

# See also:
#   https://oeis.org/A253597
#   https://oeis.org/A253598

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMPz;

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = divint($x, $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub lucas_carmichael_from_multiple ($A, $B, $m, $lambda, $p, $k, $callback) {

    my $y = rootint(($B / $m), $k);

    if ($k == 1) {

        my $x = vecmax($p, divceil($A, $m));

        $y = vecmin(773_602, $y);

        forprimes {
            if ($m % $_ != 0) {
                my $t = $m * $_;
                if (($t + 1) % $lambda == 0 and ($t + 1) % ($_ + 1) == 0) {
                    $callback->($t);
                }
            }
        } $x, $y;

        return;
    }

    for (my $r ; $p <= $y ; $p = $r) {

        $r = next_prime($p);
        $m % $p == 0 and next;
        is_smooth($p+1, 29) || next;
        last if ($p > 20_000);

        my $L = lcm($lambda, $p + 1);
        gcd($L, $m) == 1 or next;

        my $t = $m * $p;
        my $u = divceil($A, $t);
        my $v = ($B / $t);

        if ($u <= $v) {
            __SUB__->($A, $B, $t, $L, $r, $k - 1, $callback);
        }
    }
}

sub lucas_carmichael_divisible_by ($m) {

    $m >= 1 or return;
    $m % 2 == 0 and return;
    is_square_free($m) || return;
    gcd($m, divisor_sum($m)) == 1 or return;

    my $A = vecmax(399, $m);
    my $B = 2 * $A;

    $A = Math::GMPz->new($A);
    $B = Math::GMPz->new($B);

    $m = Math::GMPz->new($m);

    my $L = vecmax(1, lcm(map { $_ + 1 } factor($m)));

    my @found;

    for (; ;) {

        say "# Sieving ($A, $B)";
        for my $k ((is_prime($m) ? 2 : 1) .. 1000) {

            my @P;
            for (my $p = 3 ; scalar(@P) < $k ; $p = next_prime($p)) {
                if ($m % $p != 0 and $L % $p != 0 and is_smooth($p+1, 29)) {
                    push @P, $p;
                }
            }

            last if (vecprod(@P, $m) > $B);

            say "# Checking: k = $k";

            my $callback = sub ($n) {
                say $n;
                push @found, $n;
                $B = vecmin($B, $n);
            };

            lucas_carmichael_from_multiple($A, $B, $m, $L, $P[0], $k, $callback);
        }

        last if @found;

        $A = $B + 1;
        $B = 2 * $A;
    }

    vecmin(@found);
}

#~ lucas_carmichael_divisible_by(1) == 399 or die;
#~ lucas_carmichael_divisible_by(3) == 399 or die;
#~ lucas_carmichael_divisible_by(3 * 7) == 399 or die;
#~ lucas_carmichael_divisible_by(7 * 19) == 399 or die;

#say join(', ', map { lucas_carmichael_divisible_by($_) } @{primes(3, 50)});
#say join(', ', map { lucas_carmichael_divisible_by($_) } 1..100);

#lucas_carmichael_divisible_by(Math::GMPz->new("11160493497496010380479442945147306718821983182885"));
lucas_carmichael_divisible_by(Math::GMPz->new("33226747402673571560714119010730997321228928534495"));
