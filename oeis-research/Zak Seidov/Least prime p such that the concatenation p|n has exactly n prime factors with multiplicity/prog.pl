#!/usr/bin/perl

# a(n) is the least prime p such that the concatenation p|n has exactly n prime factors with multiplicity.
# https://oeis.org/A358596

# Known terms:
#   3, 2, 83, 2, 67, 41, 947, 4519, 15659081, 2843, 337957, 389, 1616171, 6132829, 422116888343, 24850181, 377519743, 194486417892947, 533348873, 324403, 980825013273164555563, 25691144027, 273933405157, 1238831928746353181, 311195507789, 129917586781, 2159120477658983490299

use 5.036;
use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(uniq);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub almost_prime_numbers ($A, $B, $k, $valid_primes, $callback) {

    $A = vecmax($A, Math::GMPz->new(2)**$k);

    my $mod = powint(10, length($k));

    sub ($m, $lo, $j) {

        my $hi = rootint(divint($B, $m), $j);

        if ($lo > $hi) {
            return;
        }

        if ($j == 1) {

            # TODO: generate primes x that satisfiy the following congruence, including when gcd(m,mod) != 1:
            #   m*x == k (mod 10^length(k))

            $lo = vecmax($lo, divceil($A, $m));

            if ($lo > $hi) {
                return;
            }

            if (gcd($m, $mod) == 1) {

                my $t = mulmod(invmod($m, $mod), $k, $mod);
                $t > $hi && return;
                $t += $mod while ($t < $lo);

                for (my $p = $t ; $p <= $hi ; $p += $mod) {
                    if (exists($valid_primes->{$p})) {
                        my $n = $m*$p;
                        my ($q, $r) = divrem($n, $mod);
                        if ($r == $k and is_prime($q)) {
                            $B = $n if ($n < $B);
                            $callback->($q);
                        }
                    }
                }

                return;
            }

            forprimes {
                if (exists $valid_primes->{$_}) {
                    my $n = $m*$_;
                    my ($q, $r) = divrem($n, $mod);
                    if ($r == $k and is_prime($q)) {
                        $B = $n if ($n < $B);
                        $callback->($q);
                    }
                }
            } $lo, $hi;

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {
            exists($valid_primes->{$p}) or next;
            __SUB__->($m*$p, $p, $j - 1);
        }

    }->(Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    my $x = Math::GMPz->new(2)**$n;
    my $y = 3*$x;

    my %valid_primes;

    foreach my $p (@{primes($x, $x+1e5)}) {
        $valid_primes{$_} = 1 for uniq(factor($p . $n));
    }

    while (1) {
        my @arr;
        almost_prime_numbers($x, $y, $n, \%valid_primes, sub ($k) { push @arr, $k });
        @arr = sort { $a <=> $b } @arr;
        @arr and return $arr[0];
        $x = $y+1;
        $y = 3*$x;
    }
}

foreach my $n(1..100) {
    say "$n ", a($n);
}

__END__
1 3
2 2
3 83
4 2
5 67
6 41
7 947
8 4519
9 15659081
10 2843
11 337957
12 389
13 1616171
14 6132829
15 422116888343
16 24850181
17 377519743
