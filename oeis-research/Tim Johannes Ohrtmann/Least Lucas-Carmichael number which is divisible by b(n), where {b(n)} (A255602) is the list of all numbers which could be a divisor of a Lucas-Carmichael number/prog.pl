#!/usr/bin/perl

# a(n) = least Lucas-Carmichael number which is divisible by b(n), where {b(n)} (A255602) is the list of all numbers which could be a divisor of a Lucas-Carmichael number.
# https://oeis.org/A253598

# Method for finding the smallest Lucas-Carmichael number divisible by k.

# There are no known upper-bounds for the following values of k:
#   2019 2199 2433 2469 2559 2631 2721 2811 2973 2991

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = divint($x, $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub lucas_carmichael_from_multiple ($A, $B, $m, $L, $lo, $k, $callback) {

    my $hi = rootint(divint($B, $m), $k);

    if ($lo > $hi) {
        return;
    }

    if ($k == 1) {

        $lo = vecmax($lo, divceil($A, $m));
        $lo > $hi && return;

        my $t = mulmod(invmod($m, $L) // (return), -1, $L);
        $t > $hi && return;
        $t += $L while ($t < $lo);

        for (my $p = $t ; $p <= $hi ; $p += $L) {
            if ($m % $p != 0 and is_prime($p)) {
                my $n = $m * $p;
                if (($n + 1) % ($p + 1) == 0) {
                    $callback->($n);
                }
            }
        }

        return;
    }

    foreach my $p (@{primes($lo, $hi)}) {

        $m % $p == 0 and next;
        gcd($m, $p + 1) == 1 or next;

        __SUB__->($A, $B, $m * $p, lcm($L, $p + 1), $p + 1, $k - 1, $callback);
    }
}

sub lucas_carmichael_divisible_by ($m) {

    $m >= 1 or return;
    $m % 2 == 0 and return;
    is_square_free($m) || return;
    gcd($m, divisor_sum($m)) == 1 or return;

    my $A = vecmax(399, $m);
    my $B = 2 * $A;

    my $L = vecmax(1, lcm(map { $_ + 1 } factor($m)));

    my @found;

    for (; ;) {
        say "# Sieving range: ($A, $B)";
        for my $k ((is_prime($m) ? 2 : 1) .. 1000) {

            my @P;
            for (my $p = 3 ; scalar(@P) < $k ; $p = next_prime($p)) {
                if ($m % $p != 0 and $L % $p != 0) {
                    push @P, $p;
                }
            }

            last if (vecprod(@P, $m) > $B);

            my $callback = sub ($n) {
                say "# Found upper-bound: $n";
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

say lucas_carmichael_divisible_by(2019);

__END__
lucas_carmichael_divisible_by(1) == 399      or die;
lucas_carmichael_divisible_by(3) == 399      or die;
lucas_carmichael_divisible_by(3 * 7) == 399  or die;
lucas_carmichael_divisible_by(7 * 19) == 399 or die;

say join(', ', map { lucas_carmichael_divisible_by($_) } @{primes(3, 50)});
say join(', ', map { lucas_carmichael_divisible_by($_) } 1 .. 100);

__END__
399, 935, 399, 935, 2015, 935, 399, 4991, 51359, 2015, 1584599, 20705, 5719, 18095
399, 399, 935, 399, 935, 2015, 935, 399, 399, 4991, 51359, 2015, 8855, 1584599, 9486399, 20705, 5719, 18095, 2915, 935, 399, 46079, 162687, 2015, 22847, 46079, 16719263, 8855, 12719, 7055, 935, 80189, 189099039, 104663
