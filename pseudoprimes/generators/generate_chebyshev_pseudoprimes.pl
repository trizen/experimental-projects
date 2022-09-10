#!/usr/bin/perl

# Generate Chebyshev pseudoprimes.
# https://oeis.org/A175530

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    my $max_p = 3457;

    $A = vecmax($A, pn_primorial($k+1)>>1);

    sub ($m, $lambda, $lambda2, $p, $k, $u = undef, $v = undef) {

        if (defined($u) and $u > $v) {
            return;
        }

        if ($k == 1) {

            $v = vecmin($v, $max_p);

            if ($u > $v) {
                return;
            }

            forprimes {
                my $t = $m*$_;
                my $l1 = lcm($lambda, $_-1);
                my $l2 = lcm($lambda2, $_+1);
                my $x = $t % $l1;
                my $y = $t % $l2;
                if (($x  == 1 or $x == $l1-1) and ($y == 1 or $y == $l2-1)) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for (my $r; $p <= $s; $p = $r) {

            last if ($p > $max_p);

            $r = next_prime($p);

            is_smooth($p - 1, 127) || next;
            is_smooth($p + 1, 191) || next;
            is_smooth($p*$p - 1, 191) || next;
            #is_smooth($p*$p - 1, 127) || next;

            my $L = lcm($lambda, $p-1);
            gcd($L, $m) == 1 or next;

            my $L2 = lcm($lambda2, $p+1);
            gcd($L2, $m) == 1 or next;

            #is_smooth($p*$p - 1, 127) || next;
            #is_smooth($p - 1, 19) || next;

            # gcd($m*$p, euler_phi($m*$p)) == 1 or die "$m*$p: not cyclic";

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $L2, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(Math::GMPz->new(1), 1, 1, 3, $k);
}

use Math::GMPz;

my $k    = 14;
#my $from = Math::GMPz->new("1");
#my $upto = $from+100;
my $from = Math::GMPz->new("734097107648270852639");
my $upto = 2*$from;

while (1) {
    say ":: [$k] Sieving ($from, $upto)";
    carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });
    $from = $upto+1;
    $upto = 2*$from;
}
