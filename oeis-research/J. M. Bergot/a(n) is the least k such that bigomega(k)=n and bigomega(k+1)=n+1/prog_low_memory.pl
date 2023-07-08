#!/usr/bin/perl

# a(n) is the least k such that A001222(k)=n and A001222(k+1)=n+1.
# https://oeis.org/A322300

# Known terms:
#   1, 3, 26, 99, 495, 728, 1215, 6560, 309824, 1896128, 1043199, 15752960, 178149375, 399112191, 4226550272, 7219625984, 45990608895, 558743781375, 1565795778560

# Upper-bounds:
#   a(20) <= 271611680260095
#   a(20) <= 79776206553087

# New terms:
#   a(19) = 28996228218879
#   a(20) = 63685431525375
#   a(21) = 45922887663615

# Lower-bounds:
#   a(22) > 1377686629908450

use 5.036;
use ntheory qw(:all);

my $n = 22;

my $from = 1;
my $upto = 2;

$from = 1377686629908450;
$upto = 2*$from;

while (1) {

    say "Sieving range: ($from, $upto)";

    foralmostprimes {
        if (is_almost_prime($n, $_-1)) {
            printf("a(%s) = %s\n", $n, $_-1);
            exit;
        }
    } $n+1, $from, $upto;

    $from = $upto+1;
    $upto = 2*$from;
}
