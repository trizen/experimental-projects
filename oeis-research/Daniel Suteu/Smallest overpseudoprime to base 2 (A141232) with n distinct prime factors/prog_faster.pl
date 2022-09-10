#!/usr/bin/perl

# Smallest overpseudoprime to base 2 (A141232) with n distinct prime factors.
# https://oeis.org/A353409

# Known terms:
#   2047, 13421773, 14073748835533

# Upper-bounds:
#   a(5) <= 1376414970248942474729
#   a(6) <= 48663264978548104646392577273
#   a(7) <= 294413417279041274238472403168164964689
#   a(8) <= 98117433931341406381352476618801951316878459720486433149
#   a(9) <= 1252977736815195675988249271013258909221812482895905512953752551821

# New terms confirmed (03 September 2022):
#   a(5) = 1376414970248942474729
#   a(6) = 48663264978548104646392577273
#   a(7) = 294413417279041274238472403168164964689

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use Memoize qw(memoize);
use Math::GMPz;

memoize('inverse_znorder_primes');

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x,$y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub inverse_znorder_primes($base, $lambda) {
    my %seen;
    grep { znorder($base, $_) == $lambda } grep { !$seen{$_}++ } factor(subint(powint($base, $lambda), 1));
}

sub squarefree_fermat_overpseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            if ($lambda <= 135) {
                foreach my $p (inverse_znorder_primes($base, $lambda)) {
                    next if $p < $u;
                    next if $p > $v;
                    if (($m*$p - 1)%$lambda == 0) {
                        $callback->($m*$p);
                    }
                }
                return;
            }

            if (prime_count_lower($v)-prime_count_lower($u) < divint($v-$u, $lambda)) {
                forprimes {
                    if (($m*$_ - 1)%$lambda == 0 and powmod($base, $lambda, $_) == 1 and znorder($base, $_) == $lambda) {
                        $callback->($m*$_);
                    }
                } $u, $v;
                return;
            }

            for(my $w = $lambda * divceil($u-1, $lambda); $w <= $v; $w += $lambda) {
                if (is_prime($w+1) and powmod($base, $lambda, $w+1) == 1) {
                    my $p = $w+1;
                    if (($m*$p - 1)%$lambda == 0 and znorder($base, $p) == $lambda) {
                        $callback->($m*$p);
                    }
                }
            }

            return;
        }

        my $s = rootint($B/$m, $k);

        if ($lambda > 1 and $lambda <= 135) {
            for my $q (inverse_znorder_primes($base, $lambda)) {

                next if ($q < $p);
                next if ($q > $s);

                my $t = $m*$q;
                my $u = divceil($A, $t);
                my $v = $B/$t;

                if ($u <= $v) {
                    my $r = next_prime($q);
                    __SUB__->($t, $lambda, $r, $k-1, (($k==2 && $r>$u) ? $r : $u), $v);
                }
            }
            return;
        }

        if ($lambda > 1) {
            for(my $w = $lambda * divceil($p-1, $lambda); $w <= $s; $w += $lambda) {
                if (is_prime($w+1) and powmod($base, $lambda, $w+1) == 1) {
                    my $p = $w+1;

                    $lambda == znorder($base, $p) or next;
                    $base % $p == 0 and next;

                    my $t = $m*$p;
                    my $u = divceil($A, $t);
                    my $v = $B/$t;

                    if ($u <= $v) {
                        my $r = next_prime($p);
                        __SUB__->($t, $lambda, $r, $k-1, (($k==2 && $r>$u) ? $r : $u), $v);
                    }
                }
            }

            return;
        }

        for (my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);
            $base % $p == 0 and next;

            my $L = znorder($base, $p);
            $L == $lambda or $lambda == 1 or next;

            gcd($L, $m) == 1 or next;

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = $B/$t;

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(Math::GMPz->new(1), 1, 2, $k);
}

sub a($n) {
    my $x = pn_primorial($n);
    my $y = 2*$x;

    $x = Math::GMPz->new("$x");
    $y = Math::GMPz->new("$y");

    for (;;) {
        my @arr;
        squarefree_fermat_overpseudoprimes_in_range($x, $y, $n, 2, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (8) {
    say "a($n) = ", a($n);
}

__END__
a(2) = 2047
a(3) = 13421773
a(4) = 14073748835533
a(5) = 1376414970248942474729
a(6) = 48663264978548104646392577273
a(7) = 294413417279041274238472403168164964689
