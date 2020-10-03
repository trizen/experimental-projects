#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 07 July 2019
# https://github.com/trizen

use 5.014;
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::GMPz;

prime_precalc(1e6);

#use Math::AnyNum qw(:overload);

sub f($n) {

    my $count = -1;

    while (is_semiprime($n) && !is_square($n)) {
        my ($x, $y) = factor($n);
        $n = ($y - $x);
        ++$count;
    }

    $count;
}

use Memoize qw(memoize);
memoize('a');

sub a($n) {

    if ($n == 0) {
        return 6;
    }

    if ($n <= 1) {

        #return [    6, 34, 82, 226, 687, 4786, 14367, 28738, 373763, 21408927]->[$n];
        #my $k = 2519240627,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
        #return $k * ($k + Math::GMPz->new("7136306"));
        return Math::GMPz->new(2519240627);

        #return 26;
        #return 79139915
        #return Math::AnyNum->new("79139915");
    }

    #if ($n <= ) {
    #    return 6
    #}

    my $t = a($n - 1);
    my $res;

    #~ foreach my $mul(10000..20000) {
    #~ foreach my $rem(0..20) {
    #~ foreach my $add(1..100) {
    #~ $res = ($t + $add)*$mul + $rem;
    #~ if (f($res) >= $n) {
    #~ return $res;
    #~ }
    #~ }
    #~ }
    #~ }

    #my @collect;

    for (my $x = 2 ; $x <= 100000 ; $x = next_prime($x)) {

        my $r = $x * ($t + $x);

        if (is_semiprime($r) and f($r) >= $n) {

            for (my $y = 2 ; $y <= 100000 ; $y = next_prime($y)) {
                my $u = $y * ($r + $y);
                if (is_semiprime($u) and f($u) > $n) {
                    return $r;
                }
            }
        }
    }

    #$collect[rand @collect]

    #if (f($r) >= $n) {
    #    return $r;
    #}

    #~ while (1) {

    #~ for(my $x = 2; $x <= 100; $x = next_prime($x)) {
    #~ if (f($x * ($t+$x)) >= $n) {
    #~ $z = $x;
    #~ last;
    #~ }
    #~ }

    #~ last if defined($z);
    #~ $t = next_prime($t);
    #~ $t += 1;
    #~ }

    #$z * ($t+$z);
    #$res;
}

foreach my $k (0 .. 30) {
    say "a(", f(a($k)), ") <= ", a($k);
}

__END__
for k in (0..12) {
    say "a(#{k}) <= #{a(k)}"
}
