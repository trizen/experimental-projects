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

sub lucas_carmichael_numbers_in_range ($A,  $k, $primes, $callback) {

    $A = vecmax($A, pn_primorial($k));

    my $end = $#{$primes};

    sub ($m, $lambda, $j, $k) {

   #     my $y = rootint(divint($B, $m), $k);

        if ($k == 1) {

            my $x = divceil($A, $m);

            if ($primes->[-1] < $x) {
                return;
            }

            foreach my $i ($j .. $end) {
                my $p = $primes->[$i];

              #  last if ($p > $y);
                next if ($p < $x);

                my $t = $m * $p;

                if (($t + 1) % $lambda == 0 and ($t + 1) % ($p + 1) == 0) {
                    $callback->($t);
                }
            }

            return;
        }

        my $base = 2;
        my $k_exp = 0;
        my $congr = -1;

        foreach my $i ($j .. $end) {
            my $p = $primes->[$i];
         #   last if ($p > $y);

            #$base % $p == 0 and next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                    or next;
            powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

            my $L = lcm($lambda, $p + 1);
            gcd($L, $m) == 1 or next;

            # gcd($m*$p, divisor_sum($m*$p)) == 1 or die "$m*$p: not Lucas-cyclic";

            my $t = $m * $p;
          #  my $u = divceil($A, $t);
          #  my $v = divint($B, $t);

          #  if ($u <= $v) {
                __SUB__->($t, $L, $i + 1, $k - 1);
          #  }
        }
      }
      ->(Math::GMPz->new(1), 1, 0, $k);
}

use IO::Handle;

open my $fh, '>>', 'lc6 1 -1.txt';
$fh->autoflush(1);

#foreach my $lambda (2 .. 1e6) {
while (<>) {
    chomp(my $lambda = $_);

    $lambda > 1e6 or next;

    say "# Generating: $lambda";

    my $lambda_gpf = (factor($lambda))[-1];
    my @primes = grep { $_ > 2 and is_prime($_) and $lambda % $_ != 0 and is_smooth($_-1, $lambda_gpf) } map { $_ - 1 } divisors($lambda);

    foreach my $k (3 .. 100) {
        if (binomial(scalar(@primes), $k) < 1e6) {
            lucas_carmichael_numbers_in_range(~0, $k, \@primes, sub ($n) { say $n; say $fh $n; });
        }
    }
}