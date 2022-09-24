#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 24 September 2022
# https://github.com/trizen

# Generate all the squarefree strong Fermat pseudoprimes to given a base with n prime factors in a given range [A,B]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMPz;

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = ($x / $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub squarefree_strong_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, Math::GMPz->new(pn_primorial($k)));

    $A > $B and return;

    my $generator = sub ($m, $lambda, $p, $k, $k_exp, $congr, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                my $valuation = valuation($_ - 1, 2);
                if ($valuation > $k_exp
                    and powmod($base, (($_ - 1) >> $valuation) << $k_exp, $_) == ($congr % $_)) {
                    my $t = $m * $_;
                    if (($t - 1) % $lambda == 0 and ($t - 1) % znorder($base, $_) == 0) {
                        say "# Found: $t";
                        $callback->($t);
                    }
                }
            } $u, $v;

            return;
        }

        my $s = rootint($B / $m, $k);

        for (my $r ; $p <= $s ; $p = $r) {

            $r = next_prime($p);
            $base % $p == 0 and next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                    or next;
            powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

            my $z = znorder($base, $p);
            my $L = lcm($lambda, $z);

            gcd($L, $m) == 1 or next;

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = ($B / $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, $k_exp, $congr, (($k == 2 && $r > $u) ? $r : $u), $v);
            }
        }
    };

    say "# Sieving range: [$A, $B]";

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), 1, 2, $k, 0, 1);

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (0 .. logint($B, 2)) {
        say "# Generating with v = $v";
        $generator->(Math::GMPz->new(1), 1, 2, $k, $v, -1);
    }
}

# Generate all the squarefree strong Fermat pseudoprimes to base 2 with 3 prime factors in the range [1, 10^7]

my $k = 10;

my $from = Math::GMPz->new(2);
my $upto = Math::GMPz->new(pn_primorial($k));

while (1) {

    my @found;
    squarefree_strong_fermat_pseudoprimes_in_range($from, $upto, $k, 2, sub ($n) { push @found, $n });

    if (@found) {
        @found = sort {$a <=> $b} @found;
        say "Terms: @found";
        say "a($k) = $found[0]";
        last;
    }

    $from = $upto+1;
    $upto = 2*$from;
}
