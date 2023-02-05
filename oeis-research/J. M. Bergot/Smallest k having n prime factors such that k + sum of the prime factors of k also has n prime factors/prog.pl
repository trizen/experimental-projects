#!/usr/bin/perl

# a(n) = smallest k having n prime factors such that k + sum of the prime factors of k also has n prime factors.
# https://oeis.org/A159235

# Known terms:
#   9, 63, 16, 162, 1904, 1056, 15984, 28000, 75520, 593280, 575424, 10209280, 58028032, 82616320, 755404800, 2255519744, 6636896256, 98721275904, 108417761280, 1303972577280, 2009909428224, 2344618524672, 50095111274496

# Upper-bounds:
#   a(27) <= 3166588152840192

# New terms:
#   a(25) = 114342775226368
#   a(26) = 456293923946496
#   a(27) = 2380822275424256

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub almost_prime_count_range ($n, $from, $upto) {
    almost_prime_count($n, $upto) - almost_prime_count($n, $from-1);
}

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub almost_prime_numbers ($A, $B, $k, $callback) {

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
            __SUB__->($t, $p, $k - 1);
            $p = next_prime($p);
        }
    }->(1, 2, $k);
}

sub upper_bound($n, $from = 2, $upto = 2*$from) {

    say "\n:: Searching an upper-bound for a($n)\n";

    my $max = undef;

    while (1) {

        my $count = almost_prime_count_range($n, $from, $upto);

        if ($count > 0) {

            say "Sieving range: [$from, $upto]";
            say "This range contains: $count elements\n";

            almost_prime_numbers($from, $upto, $n, sub ($v) {
                if ((defined($max) ? ($v < $max) : 1) and is_almost_prime($n, addint($v, vecsum(factor($v))))) {
                    say "a($n) <= $v";
                    $max = $v;
                }
            })
        }

        if (defined($max)) {
            say "Found term: a($n) = $max";
            return $max;
        }

        $from = $upto+1;
        $upto *= 2;
    }
}

upper_bound(27);
