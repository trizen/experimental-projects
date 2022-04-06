#!/usr/bin/perl

# Squares in A213544.
# https://oeis.org/A352788

# Known terms:
#   1, 9, 25, 10510564

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use ntheory qw(:all);

sub triangular ($n) {
    divint(mulint($n, $n + 1), 2);
}

sub square_pyramidal ($n) {
    divint(vecprod($n, $n + 1, mulint(2, $n) + 1), 6);
}

sub partial_sums_of_euler_totient ($n) {
    my $s = sqrtint($n);

    my @euler_sum_lookup = (0);

    my $lookup_size = int(2 * rootint($n, 3)**2);
    my @euler_phi   = euler_phi(0, $lookup_size);

    foreach my $i (1 .. $lookup_size) {
        $euler_sum_lookup[$i] = addint($euler_sum_lookup[$i - 1], mulint($i, $euler_phi[$i]));
    }

    my %seen;

    sub ($n) {

        if ($n <= $lookup_size) {
            return $euler_sum_lookup[$n];
        }

        if (exists $seen{$n}) {
            return $seen{$n};
        }

        my $s = sqrtint($n);
        my $T = square_pyramidal($n);

        foreach my $k (2 .. divint($n, $s + 1)) {
            $T = subint($T, mulint($k, __SUB__->(divint($n, $k))));
        }

        my $prev = triangular($n);

        foreach my $k (1 .. $s) {
            my $curr = triangular(divint($n, $k + 1));
            $T    = subint($T, mulint(subint($prev, $curr), __SUB__->($k)));
            $prev = $curr;
        }

        $seen{$n} = $T;

      }
      ->($n);
}

sub A213544 ($n) {
    divint(partial_sums_of_euler_totient($n) + 1, 2);
}

use Math::AnyNum qw(bsearch_le pi root ceil);

my $pi_squared = pi**2;
my $count = 0;

for(my $v = 1;  ; ) {
#for(my $v = 10065842420;  ; ) {

    my $s = mulint($v, $v);
    my $n = int(root($pi_squared * $s, 3));

    if (++$count % 1e2 == 0) {
        say ":: Searching with v = $v and n = $n";
        $count = 0;
    }

    #say "$s -- $v*$v";
    #say (($v+1)*($v+1), " -- ($v+1)*($v+1)");

    #say "n = $n";
    #say A213544($n);
    #say A213544($n+1);

    #say $n**3 / $pi_squared;
    #say (($n+1)**3 / $pi_squared);
    $v = ceil(root(Math::AnyNum::pow($n+1, 3) / $pi_squared, 2));

    #is_prime($v) || next;

    #~ say "Search with n ~ $n";

    #~ my $k = bsearch_le(
        #~ vecmax(1, $n - 10),
        #~ $n + 10,
        #~ sub ($k) {
            #~ A213544($k) <=> $s;
        #~ }
    #~ );

    my $k = "$n";
    my $t = A213544($k);

    if (is_square($t)) {
        say "$k -- $t";
        if ($t > 10510564) {
            die "Found new square: $t";
        }
    }
}
