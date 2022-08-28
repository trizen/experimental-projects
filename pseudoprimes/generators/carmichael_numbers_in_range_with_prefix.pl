#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
#use Math::GMP qw(:constant);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

use Math::GMPz;

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    #my $max_p = 313897;
    my $max_p = 10000;
    #my $m = "1056687375767188465946114009917285";
    #my $m = Math::GMPz->new("6863588485053268178811679453193455");
    my $m = Math::GMPz->new("8035018770721572330061486952496026236686375478339885");
    my $L = lcm(map {$_-1} factor($m));

    if ($L == 0) {
        $L = 1;
    }

    $A = mulint($A, $m);
    $B = mulint($B, $m);

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    return if $A > "2059832906607460252767290568443059994787898033540634712711845135488141590979778401392385";

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            $v = vecmin($v, $max_p);

            say "# Sieving: $m -> ($u, $v)" if ($v - $u > 2e6);

            if ($v-$u > 1e10) {
                die "Range too large!\n";
            }

            forprimes {
                my $t = $m*$_;
                if (($t-1)%$lambda == 0 and ($t-1)%($_-1) == 0) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for (my $r; $p <= $s; $p = $r) {

            last if ($p > $max_p);

            $r = next_prime($p);
            #is_smooth($p-1, 41) || next;

            my $t = $m*$p;
            my $L = lcm($lambda, $p-1);

            ($p >= 3 and gcd($L, $t) == 1) or next;

            # gcd($t, euler_phi($t)) == 1 or die "$t: not cyclic";

            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            $u = Math::GMPz->new("$u");
            $v = Math::GMPz->new("$v");

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->($m, $L, 3, $k);

    return 1;
}

#~ my $from = 2;
#~ my $upto = 2*$from;

#~ while (1) {

    #~ say "# Range: ($from, $upto)";

    #~ foreach my $k (2..50) {
        #~ pn_primorial($k) < $upto or last;
        #~ carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });
    #~ }

    #~ $from = $upto+1;
    #~ $upto = 2*$from;
#~ }

foreach my $k (reverse(2..100)) {

    my $base = 2;
    my $from = Math::GMPz->new(2);
    my $upto = 2*$from;

    my $pn_primorial = pn_primorial($k);

    say "# [$k] Sieving...";

    while (1) {

        if ($pn_primorial < $upto) {
            carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n }) or last;
        }

        $from = $upto+1;
        $upto = 2*$from;
    }
}
