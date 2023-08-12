#!/usr/bin/perl

# a(n) is the smallest prime p such that p-1 and p+1 both have n prime factors (with multiplicity).
# https://oeis.org/A154598

# Known terms:
#   5, 19, 89, 271, 1889, 10529, 75329, 157951, 3885569, 11350529, 98690561, 65071999, 652963841, 6548416001, 253401579521, 160283668481, 1851643543553, 3450998226943, 23114453401601, 1194899749142527, 1101483715526657, 7093521158963201

# Lower-bounds:
#   a(24) > 2^54. - Jon E. Schoenfield, Feb 08 2009
#   a(24) > 19108664577297956.

use 5.036;
use ntheory qw(:all);

my $n = 24;

my $from = powint(2, $n);
my $upto = 2 * $from;

#$from = powint(2, 54);
$from = 19108664577297956;
$upto = $from+1;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n, $from, $upto);

    foreach my $i (0 .. $#{$arr} - 2) {
        my $k = $arr->[$i];
        my $t = $arr->[$i + 1];
        $t = $arr->[$i + 2] if ($t < $k + 2);
        if ($t == $k + 2 and is_prime($k+1)) {
            printf("a(%s) = %s\n", $n, $k + 1);
            exit;
        }
    }

    $from = $upto - 4;
    $upto = int(1.001 * $from);
}
