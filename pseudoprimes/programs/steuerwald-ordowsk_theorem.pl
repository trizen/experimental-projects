#!/usr/bin/perl

# On Steuerwald's theorem (1948)

# Tomasz Ordowsk:
#   Let m = (b^n-1)/(b-1).
#   Theorem: if m == 1 (mod n), then b^(m-1) == 1 (mod m).
#   Conjecture: if b^(m-1) == 1 (mod m), then m == 1 (mod n).

# The conjecture is probably true. No counter-example is known.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %seen;
my $m = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    Math::GMPz::Rmpz_set_str($m, $n, 10);

    foreach my $b (2, 3, 5) {

        my $t = $m * ($b-1) + 1;
        if (Math::GMPz::Rmpz_perfect_power_p($t)) {

            my $n = is_power($t);

            $n > 0 or next;

            say "Testing: n = $n and b = $b";

            if ($m % $n == 1) {
                next;
            }

            (Math::GMPz->new($b)**$n - 1) / ($b-1) == $m
                or next;

            if (powmod($b, $m-1, $m) == 1) {
                die "Counter example for $m with b = $b and n = $n";
            }
        }
    }
}
