#!/usr/bin/perl

# Generate Carmichael-Chebyshev pseudoprimes.
# https://oeis.org/A299799

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k+1)>>1);

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if (defined($u) and $u > $v) {
            return;
        }

        if ($k == 1) {

            $v = vecmin($v, 1000);

            if ($u > $v) {
                return;
            }

            forprimes {
                my $t = $m*$_;
                if (($t-1)%$lambda == 0 and ($t-1)%(($_*$_ - 1)>>1) == 0) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for (my $r; $p <= $s; $p = $r) {

            last if ($p > 1000);

            $r = next_prime($p);

            is_smooth($p - 1, 19) || next;
            is_smooth($p*$p - 1, 19) || next;

            my $L = lcm($lambda, ($p*$p-1)>>1);
            gcd($L, $m) == 1 or next;
            #is_smooth($p*$p - 1, 127) || next;
            #is_smooth($p - 1, 19) || next;

            # gcd($m*$p, euler_phi($m*$p)) == 1 or die "$m*$p: not cyclic";

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(Math::GMPz->new(1), 1, 3, $k);
}

use Math::GMPz;

my $k    = 12;
my $from = Math::GMPz->new("1");
my $upto = $from+100;

while (1) {
    say ":: [$k] Sieving ($from, $upto)";
    carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });
    $from = $upto+1;
    $upto = 2*$from;
}
