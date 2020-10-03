#!/usr/bin/perl


use 5.014;
use Math::GMPz;

use ntheory qw(is_prime kronecker valuation primes);

while (<>) {
    my ($n) = (split(' '))[-1] || next;

    $n = Math::GMPz->new($n);

    my $l = kronecker($n, 5);
    my $t = $n - $l;

    foreach my $k(2..1000) {
        if (is_prime($t*$k + $l)) {
            say $t*$k + $l;
        }
    }

    say $n;

    foreach my $k(1..10) {
        if (is_prime(($t << $k) + $l)) {
            say (($t<<$k) + $l);
        }
    }

    foreach my $p(1..1000) {

        Math::GMPz::Rmpz_divisible_ui_p($t, $p) || next;

        my $w = $t+0;
        my $v = valuation($t, $p);

        for (1..$v) {

            $w /= $p;

            if (is_prime($w + $l)) {
                say $w + $l;
            }
        }
    }
}
