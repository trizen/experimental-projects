#!/usr/bin/perl

# a(n) is the least k such that k^j+2 is prime for j = 1 to n but not n+1.
# https://oeis.org/A359396

# Known terms:
#   5, 9, 105, 3, 909, 4995825, 28212939

# a(8) > 10^11. - Lucas A. Brown, Jan 11 2023

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my $n = 8;
my $z = Math::GMPz::Rmpz_init();

#my $crt = chinese([1, 2], [0, 3], [-1, 5], [-1, 7], [-1, 11]);
my $crt = chinese([1, 2], [0, 3], [0, 5], [2, 7], [-1, 11]);
my $mod = lcm(2, 3, 5, 7, 11);

say "For n = $n, CRT = ($crt, $mod)";

for (my $k = divint(1e11, $mod) * $mod ; ; $k += $mod) {
    my $m = $k + $crt;

    if (is_prime($m + 2)) {

        my $count = 1;
        my $j     = 2;

        while (1) {
            Math::GMPz::Rmpz_ui_pow_ui($z, $m, $j);
            Math::GMPz::Rmpz_add_ui($z, $z, 2);
            Math::GMPz::Rmpz_probab_prime_p($z, 0) || last;
            ++$j;
            ++$count;
        }

        if ($count >= $n) {
            die "a($count) <= $m";
        }
    }
}
