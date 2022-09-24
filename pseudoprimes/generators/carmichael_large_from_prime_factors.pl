#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Lucas-Carmichael numbers with n prime factors in a given range [A,B], using a given list of prime factors. (not in sorted order)

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

sub carmichael_numbers_in_range ($A, $k, $primes, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $end = $#{$primes};

    sub ($m, $lambda, $j, $k) {

        #my $y = rootint($B / $m, $k);

        if ($k == 1) {

            my $x = divceil($A, $m);

            if ($primes->[-1] < $x) {
                return;
            }

            foreach my $i ($j .. $end) {
                my $p = $primes->[$i];

                #last if ($p > $y);
                next if ($p < $x);

                my $t = $m * $p;

                if (($t - 1) % $lambda == 0 and ($t - 1) % ($p - 1) == 0) {
                    $callback->($t);
                }
            }

            return;
        }

        foreach my $i ($j .. $end) {
            my $p = $primes->[$i];
            #last if ($p > $y);

            my $L = lcm($lambda, $p - 1);
            gcd($L, $m) == 1 or next;

            # gcd($m*$p, divisor_sum($m*$p)) == 1 or die "$m*$p: not Lucas-cyclic";

            #~ my $t = $m * $p;
            #~ my $u = divceil($A, $t);
            #my $v = $B / $t;

            #if ($u <= $v) {
                __SUB__->($m*$p, $L, $i + 1, $k - 1);
            #}
        }
      }
      ->(Math::GMPz->new(1), 1, 0, $k);
}

sub is_pomerance_prime ($p) {

    # p == 3 (mod 8) and (5/p) = -1
    # is_congruent(p, 3, 8) && (kronecker(5, p) == -1) &&

    # (p-1)/2 and (p+1)/4 are squarefree
    # is_squarefree((p-1)/2) && is_squarefree((p+1)/4) &&

    # all factors q of (p-1)/2 are q == 1 (mod 4)
    # factor((p-1)/2).all { |q|
    #     is_congruent(q, 1, 4)
    # } &&

    # all factors q of (p+1)/4 are q == 3 (mod 4)
    # factor((p+1)/4).all {|q|
    #    is_congruent(q, 3, 4)
    # }

    # p == 3 (mod 8)
    $p%8 == 3 or return;

    # (5/p) = -1
    #kronecker(5, $p) == -1 or return;

    # (p-1)/2 and (p+1)/4 are squarefree
    (is_square_free(($p-1)>>1) and is_square_free(($p+1)>>2)) || return;

    # all prime factors q of (p-1)/2 are q == 1 (mod 4)
    (vecall {  $_%4 == 1 } factor(($p-1)>>1)) || return;

    # all prime factors q of (p+1)/4 are q == 3 (mod 4)
    (vecall {  $_%4 == 3 } factor(($p+1)>>2)) || return;

    return 1;
}

use IO::Handle;
open my $fh, '>>', 'carmichael_with_many_factors_7.txt';
$fh->autoflush(1);

#foreach my $lambda (2..1e6) {
while (<>) {
    chomp(my $lambda = $_);

    #$lambda >= 1e10 or next;

    say "# Generating: $lambda";

    my @primes = grep { $_ > 2 and $lambda % $_ != 0 and is_prime($_) and ($_%80==3) } map { $_ + 1 } divisors($lambda);

    foreach my $k (3..320) {
        last if ($k > scalar(@primes));
        $k % 2 == 1 or next;
        if (binomial(scalar(@primes), $k) < 1e6) {
            say "# k = $k -- primes: ", scalar(@primes);
            carmichael_numbers_in_range(Math::GMPz->new(~0), $k, \@primes, sub ($n) { say $n; say $fh $n; });
        }
    }
}
