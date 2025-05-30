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

sub carmichael_numbers_in_range ($A, $B, $k, $primes, $callback) {

    $A = vecmax($A, pn_primorial($k));

    my $end = $#{$primes};

    sub ($m, $lambda, $j, $k) {

        my $y = rootint($B / $m, $k);

        if ($k == 1) {

            my $x = divceil($A, $m);

            if ($primes->[-1] < $x) {
                return;
            }

            foreach my $i ($j .. $end) {
                my $p = $primes->[$i];

                last if ($p > $y);
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
            last if ($p > $y);

            my $L = lcm($lambda, $p - 1);
            gcd($L, $m) == 1 or next;

            # gcd($m*$p, divisor_sum($m*$p)) == 1 or die "$m*$p: not Lucas-cyclic";

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = $B / $t;

            if ($u <= $v) {
                __SUB__->($t, $L, $i + 1, $k - 1);
            }
        }
      }
      ->(Math::GMPz->new(1), 1, 0, $k);
}

use IO::Handle;

open my $fh, '>>', 'carm_from_lambdas.txt';
$fh->autoflush(1);

#foreach my $lambda (2..1e6) {
while (<>) {
    chomp(my $lambda = $_);

    $lambda >= 3588 or next;

    say "# Generating: $lambda";

    my @primes = grep { $_ > 2 and $lambda % $_ != 0 and ($_%4 == 3) and is_prime($_) and is_smooth($_+1, 1e3) } map { $_ + 1 } divisors($lambda);

    foreach my $k (3 .. 100) {
        $k % 2 == 1 or next;
        if (binomial(scalar(@primes), $k) < 1e6) {
            carmichael_numbers_in_range(Math::GMPz->new(~0), Math::GMPz->new(10)**100, $k, \@primes, sub ($n) { say $n; say $fh $n; });
        }
    }
}
