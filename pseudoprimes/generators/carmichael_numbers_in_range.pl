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

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = divint($x, $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, divint(pn_primorial($k + 1), 2));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            if ($v - $u > 1e10) {
                die "Range too large!\n";
            }

            forprimes {
                my $t = $m * $_;
                if (($t - 1) % $lambda == 0 and ($t - 1) % ($_ - 1) == 0) {
                    $callback->($t);
                }
            }
            $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for (my $r ; $p <= $s ; $p = $r) {

            $r = next_prime($p);

            my $L = lcm($lambda, $p - 1);
            gcd($L, $m) == 1 or next;

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k == 2 && $r > $u) ? $r : $u), $v);
            }
        }
      }
      ->(1, 1, 3, $k);
}

# Generate all the 5-Carmichael numbers in the range [100, 10^8]

my $k    = 5;
my $from = 100;
my $upto = 1e8;

my @arr;
carmichael_numbers_in_range($from, $upto, $k, sub ($n) { push @arr, $n });

say join(', ', sort { $a <=> $b } @arr);

__END__
825265, 1050985, 9890881, 10877581, 12945745, 13992265, 16778881, 18162001, 27336673, 28787185, 31146661, 36121345, 37167361, 40280065, 41298985, 41341321, 41471521, 47006785, 67371265, 67994641, 69331969, 74165065, 75151441, 76595761, 88689601, 93614521, 93869665
