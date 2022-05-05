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

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub almost_prime_numbers ($n, $k, $callback) {

    sub ($m, $p, $r) {

        if ($r == 1) {

            foreach my $q (@{primes($p, divint($n, $m))}) {
                $callback->(mulint($m, $q));
            }

            return;
        }

        my $s = rootint(divint($n, $m), $r);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->(mulint($m, $q), $q, $r - 1);
        }
    }->(1, 2, $k);
}

my $n     = 22;
my $limit = 35*45922887663615;
my $min_value = $limit+2;

almost_prime_numbers(
    $limit+1, $n+1,
    sub ($k) {
        if ($k-1 >= 30*45922887663615 and $k-1 <= $min_value and is_almost_prime($n, $k-1)) {
            $min_value = $k-1;
            printf("a(%s) <= %s\n", $n, $k-1);
        }
    }
);

__END__

# PARI/GP program

isok(n,k) = bigomega(k) == n && bigomega(k+1) == n+1;
a(n) = for(k=1, oo, if(isok(n,k), return(k))); \\ ~~~~
