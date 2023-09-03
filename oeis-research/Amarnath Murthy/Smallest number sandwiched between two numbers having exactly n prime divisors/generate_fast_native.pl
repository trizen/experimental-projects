#!/usr/bin/perl

# Smallest number sandwiched between two numbers having exactly n prime divisors.
# https://oeis.org/A088075

# Known terms:
#   3, 11, 131, 1429, 77141, 1456729, 117048931, 10326137821, 1110819807371, 140734085123059, 11639258217451019

# Upper-bounds:
#   a(8)  <= 162019241539
#   a(9)  <= 10321401544609
#   a(10) <= 2665708580358979
#   a(11) <= 306038125603829059

# Lower-bounds:
#   a(12) > 2340032226703422

use 5.036;
use ntheory qw(:all);

sub generate ($A, $B, $n) {

    $A = vecmax($A, pn_primorial($n));

    my @values = sub ($m, $lo, $j) {

        my $hi = rootint(divint($B, $m), $j);

        if ($lo > $hi) {
            return;
        }

        my @lst;

        foreach my $q (@{primes($lo, $hi)}) {

            #$q % 4 == 3 and next;

            my $v = $m * $q;

            while ($v <= $B) {
                if ($j == 1) {
                    if ($v >= $A) {
                        if (is_omega_prime($n, $v - 2)) {
                            my $t = $v - 1;
                            say("[1] Found upper-bound: ", $t);
                            $B = $t if ($t < $B);
                            push @lst, $t;
                        }

                        # if (is_omega_prime($n, $v+2)) {
                        #     my $t = $v+1;
                        #     say("[2] Found upper-bound: ", $t);
                        #     $B = $t if ($t < $B);
                        #     push @lst, $t;
                        # }
                    }
                }
                else {
                    push @lst, __SUB__->($v, $q + 1, $j - 1);
                }
                $v *= $q;
            }
        }

        return @lst;
      }
      ->(1, 2, $n);

    return sort { $a <=> $b } @values;
}

sub a ($n) {

    if ($n == 0) {
        return 1;
    }

    my $x = pn_primorial($n);
    my $y = divint(4 * $x, 3);

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v = generate($x, $y, $n);
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;
        $y = divint(4 * $x, 3);
    }
}

foreach my $n (12) {
    say "a($n) = ", a($n);
}

__END__
Sieving range: [9666908963, 12889211950]
[1] Found upper-bound: 10326137821
[2] Found upper-bound: 10326137821
a(8) = 10326137821
perl generate_fast_native.pl  11.77s user 0.07s system 92% cpu 12.845 total

Sieving range: [936934125197, 1249245500262]
[2] Found upper-bound: 1110819807371
a(9) = 1110819807371
perl generate_fast_native.pl  377.65s user 2.25s system 79% cpu 7:59.30 total

Sieving range: [265609421592701694, 354145895456935592]
[1] Found upper-bound: 306038125603829059
a(11) <= 306038125603829059
perl generate_fast_native.pl  18.31s user 0.21s system 55% cpu 33.582 total

