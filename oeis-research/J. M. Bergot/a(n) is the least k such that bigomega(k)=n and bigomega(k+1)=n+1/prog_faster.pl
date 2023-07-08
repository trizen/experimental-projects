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

my $n = 19;

my $from = 1;
my $upto = 2;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n+1, $from, $upto);

    foreach my $k (@$arr) {
        if (is_almost_prime($n, $k-1)) {
            printf("a(%s) = %s\n", $n, $k-1);
            exit;
        }
    }

    $from = $upto+1;
    $upto = 2*$from;
}

__END__
Sieving range: (4398046511103, 8796093022206)
Sieving range: (8796093022207, 17592186044414)
Sieving range: (17592186044415, 35184372088830)
a(19) = 28996228218879
perl prog_faster.pl  94.55s user 5.66s system 99% cpu 1:40.79 total

Sieving range: (8796093022207, 17592186044414)
Sieving range: (17592186044415, 35184372088830)
Sieving range: (35184372088831, 70368744177662)
a(21) = 45922887663615
perl prog_faster.pl  40.60s user 2.70s system 99% cpu 43.594 total
