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

    if (vecprod(@$primes) < $A) {
        say "# Too few and too small primes...";
        return;
    }

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $end = $#{$primes};

    sub ($m, $lambda1, $lambda2, $j, $k) {

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

                if (
                       (($t-1) % $lambda1 == 0 and ($t-1) % ($p-1) == 0)
                    or (($t+1) % $lambda2 == 0 and ($t+1) % ($p+1) == 0)
                ) {
                    $callback->($t);
                }
            }

            return;
        }

        foreach my $i ($j .. $end) {
            my $p = $primes->[$i];
            #last if ($p > $y);

            my $L1 = lcm($lambda1, $p-1);
            gcd($L1, $m) == 1 or next;

            my $L2 = lcm($lambda2, $p+1);
            gcd($L2, $m) == 1 or next;

            # gcd($m*$p, divisor_sum($m*$p)) == 1 or die "$m*$p: not Lucas-cyclic";

            #~ my $t = $m * $p;
            #~ my $u = divceil($A, $t);
            #my $v = $B / $t;

            #if ($u <= $v) {
                __SUB__->($m*$p, $L1, $L2, $i + 1, $k - 1);
            #}
        }
      }
      ->(Math::GMPz->new(1), 1, 1, 0, $k);
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
open my $fh, '>>', 'carmichael-lucas-carmichael.txt';
$fh->autoflush(1);

#foreach my $lambda (2..1e6) {
while (<>) {
    chomp(my $lambda = $_);

    #$lambda >= 1e10 or next;
    #$lambda > 2205403200 or next;
    #$lambda > 4532871872400564 or next;

    say "# Generating: $lambda";

    my @D = divisors($lambda);
    my @primes_pp1 = grep { $_ >= 5 and $lambda % $_ != 0 and is_prime($_) } map { addint($_, 1) } @D;
    my @primes_pm1 = grep { $_ >= 5 and $lambda % $_ != 0 and is_prime($_) } map { subint($_, 1) } @D;

    my %table;
    @table{@primes_pm1} = ();

    # (p^2 - 1)/2 == 0 (mod 12)
    my @primes = grep { (($_*$_ - 1)>>1) % 12 == 0 } grep { exists($table{$_}) } @primes_pp1;
    #my @primes = grep { exists($table{$_}) } @primes_pp1;

    # All primes must be congruent to each other mod 12.
    my %groups;
    foreach my $p(@primes) {
        push @{$groups{$p % 12}}, $p;
    }

    my @groups = values %groups;

    foreach my $k (5..320) {
        last if ($k > scalar(@primes));
       # $k % 2 == 1 or next;
       # if (binomial(scalar(@primes), $k) < 1e6) {
       foreach my $group (@groups) {
            next if ($k > scalar(@$group));
            say "# k = $k -- primes: ", scalar(@$group);
            carmichael_numbers_in_range(Math::GMPz->new(~0), $k, $group, sub ($n) { say $n; say $fh $n; });
        }
      #  }
    }
}
