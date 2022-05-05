#!/usr/bin/perl

# a(n) is the first k such that n = Omega(k) = Omega(k-1) + Omega(k+1), or 0 if there is no such k, where Omega is A001222.
# https://oeis.org/A338302

# Upper-bounds:
#   a(25) <= 1485324488278016
#   a(26) <= 3203995725725697

# New terms:
#   a(20) = 96467701761
#   a(21) = 2558408523776
#   a(22) = 4857090670593
#   a(23) = 24607835029504
#   a(24) = 177629755867136     (took 18 minutes to find)

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

my $n     = 25;
my $limit = 1485324488278016;

almost_prime_numbers(
    $limit, $n,
    sub ($k) {
        if (prime_bigomega($k - 1) + prime_bigomega($k + 1) == $n) {
            say "a($n) <= $k";
        }
    }
);
