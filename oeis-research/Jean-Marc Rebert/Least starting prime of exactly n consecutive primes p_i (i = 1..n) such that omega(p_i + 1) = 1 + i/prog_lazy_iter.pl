#!/usr/bin/perl

# Least starting prime of exactly n consecutive primes p_i (i = 1..n) such that omega(p_i + 1) = 1 + i.
# https://oeis.org/A373533

# Known terms:
#   5, 23, 499, 13093, 501343, 162598021, 25296334003

# This version is memory friendly.

# Lower-bounds:
#   a(8) > 786613953091
#   a(8) > 21286545113742

use 5.036;
use ntheory     qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);

my $n = 8;

my $multiplier = 1.1;
my $from = 21286545113742;
my $upto = int($multiplier * $from);

#~ my $n = 7;
#~ my $multiplier = 1.5;
#~ my $from = 2;
#~ my $upto = int($multiplier*$from);

sub omega_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k) {

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {

            if ($m == 1) {
                $q == 2 or last;
            }

            my $r = next_prime($q);

            for (my $v = $m * $q ; $v <= $B ; $v *= $q) {
                if ($k == 1) {
                    $callback->($v) if ($v >= $A);
                }
                else {
                    if ($v * $r <= $B) {
                        __SUB__->($v, $r, $k - 1);
                    }
                }
            }
        }
      }
      ->(1, 2, $k);
}

while (1) {

    my $t0 = [gettimeofday];
    say "Sieving range: ($from, $upto)";

    my $found = 0;
    my $min   = 'inf';

    omega_prime_numbers(
        $from, $upto,
        $n + 1,
        sub ($k) {

            if (is_prime($k - 1)) {

                my $q = prev_prime($k - 1);

                if (is_omega_prime($n, $q + 1)) {
                    my $ok = 1;
                    foreach my $j (3 .. $n) {
                        $q = prev_prime($q);
                        if (is_omega_prime($n - $j + 2, $q + 1)) {
                            ## ok
                        }
                        else {
                            $ok = 0;
                            last;
                        }
                    }

                    if ($ok) {
                        if (is_omega_prime($n + 2, next_prime($k) + 1)) {
                            say "a(", $n+1, ") <= $q";
                        }
                        elsif ($q < $min) {
                            say "a($n) <= $q";
                            $min = $q;
                            $found = 1;
                        }
                    }
                }
            }
        }
    );

    say "Sieving took: ", tv_interval($t0), " seconds\n";

    last if $found;

    $from = $upto;
    $upto = int($multiplier * $from);
}

__END__
Sieving range: (134217728, 268435456)
a(6) <= 220830457
a(6) <= 189657121
a(6) <= 162598021
Sieving took: 0.433438 seconds

Sieving range: (17179869184, 34359738368)
a(7) <= 26726674453
a(7) <= 25296334003
Sieving took: 13.232716 seconds

Sieving range: (17592186044416, 19351404648857)
Sieving took: 1243.065083 seconds

Sieving range: (19351404648857, 21286545113742)
Sieving took: 1492.179081 seconds

Sieving range: (21286545113742, 23415199625116)
^C
perl prog_lazy_iter.pl  4182.74s user 6.84s system 69% cpu 1:40:59.05 total
