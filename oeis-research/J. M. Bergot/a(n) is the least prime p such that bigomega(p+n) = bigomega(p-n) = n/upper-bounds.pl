#!/usr/bin/perl

# a(n) is the least prime p such that A001222(p+n) = A001222(p-n) = n.
# https://oeis.org/A333115

# Known terms:
#   23, 47, 1621, 373, 2352631, 9241, 18235603, 21968759, 27575049743, 2794997, 32503712890637, 304321037, 390917388671861, 277829661054961, 14392115869140641, 442395934703

# a(18) > 140737488355328

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub almost_prime_count_range ($n, $from, $upto) {
    almost_prime_count($n, $upto) - almost_prime_count($n, $from-1);
}

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub almost_prime_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(2, $k));

    sub ($m, $p, $k) {

        if ($k == 1) {

            forprimes {
                $callback->(mulint($m, $_));
            } vecmax($p, divceil($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        while ($p <= $s) {

            my $t = mulint($m, $p);

            # Optional optimization for tight ranges
            if (divceil($A, $t) > divint($B, $t)) {
                $p = next_prime($p);
                next;
            }

            __SUB__->($t, $p, $k - 1);
            $p = next_prime($p);
        }
    }->(1, 2, $k);
}

my $min_a18 = 140737488355328;

sub upper_bound($n, $from = 2, $upto = 2*$from) {

    say "\n:: Searching an upper-bound for a($n)\n";

    while (1) {

        my $count = almost_prime_count_range($n, $from, $upto);

        if ((($n == 18) ? ($upto > $min_a18) : 1) and $count > 0) {

            say "Sieving range: [$from, $upto]";
            say "This range contains: $count elements\n";

            if (($n == 18) ? ($from < $min_a18) : 0) {
                $from = $min_a18;
            }

            #~ foralmostprimes {
                #~ my $v = $_;

                #~ if (is_prime($v-$n) && is_almost_prime($n, $v - $n - $n)) {
                    #~ say "Found with v-n";
                    #~ die "a($n) <= ", $v-$n;
                #~ }

                #~ if (is_prime($v+$n) && is_almost_prime($n, $v + $n + $n)) {
                    #~ say "Found with v+n";
                    #~ die "a($n) <= ", ($v+$n);
                #~ }
            #~ } $n, $from, $upto;

            almost_prime_numbers_in_range($from, $upto, $n, sub ($v) {

                if (is_prime($v-$n) && is_almost_prime($n, $v - $n - $n)) {
                    say "Found with v-n";
                    die "a($n) <= ", $v-$n;
                }

                if (is_prime($v+$n) && is_almost_prime($n, $v + $n + $n)) {
                    say "Found with v+n";
                    die "a($n) <= ", ($v+$n);
                }
            })
        }

        $from = $upto+1;
        $upto *= 2;
    }
}

upper_bound(18);
