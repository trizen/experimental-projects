#!/usr/bin/perl

# Smallest base-n Fermat pseudoprime with n distinct prime factors.
# https://oeis.org/A271874

# Known terms:
#   341, 286, 11305, 2203201, 12306385

# New terms found:
#   a(7)  = 9073150801
#   a(8)  = 3958035081
#   a(9)  = 2539184851126
#   a(10) = 152064312120721
#   a(11) = 10963650080564545
#   a(12) = 378958695265110961
#   a(13) = 1035551157050957605345
#   a(14) = 57044715596229144811105
#   a(15) = 6149883077429715389052001

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
#use Math::GMP qw(:constant);
#use Math::AnyNum qw(:overload);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    my $m = 1;
    my $L = znorder($base, $m);

    $A = mulint($A, $m);
    $B = mulint($B, $m);

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            say "# Sieving: $m -> ($u, $v)" if ($v - $u > 2e6);

            if ($v-$u > 1e10) {
                die "Range too large!\n";
            }

            forprimes {
                my $t = mulint($m, $_);
                if (modint($t-1, $lambda) == 0 and modint($t-1, znorder($base, $_)) == 0) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for(my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);

            if (modint($m, $p) == 0) {
                next;
            }

            my $t = mulint($m, $p);
            my $z = znorder($base, $p) // next;
            my $L = lcm($lambda, $z);

            gcd($L, $t) == 1 or next;

            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->($m, $L, 2, $k);
}

my $k = 12;  # number of prime factors

my $from  = 1;
my $upto  = 2*$from;
my $base = $k;

while (1) {

    say "# Range ($from, $upto)";

    my $found = 0;
    my $min = 'inf';

    if ($from >= pn_primorial($k)) {
        fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) {
            say $n;
            $found = 1;
            if ($n < $min) {
                $min = $n;
            }
    });
    }

    if ($found) {
        say "a($k) = $min";
        last;
    }

    $from = $upto+1;
    $upto = $from*2;
}

__END__
