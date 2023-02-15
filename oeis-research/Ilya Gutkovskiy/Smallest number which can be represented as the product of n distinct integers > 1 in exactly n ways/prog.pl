#!/usr/bin/perl

# a(n) is the smallest number which can be represented as the product of n distinct integers > 1 in exactly n ways.
# https://oeis.org/A360590

# Known terms:
#   2, 12, 60, 420, 3456, 60060

# New terms found:
#   a(7)  = 155520
#   a(8)  = 1512000
#   a(9)  = 13063680
#   a(10) = 169344000

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub almost_primes ($n, $k, $factors, $callback, $squarefree = 0) {

    my $factors_end = $#{$factors};

    if ($k == 0) {
        return (1);
    }

    if ($k == 1) {
        return @$factors;
    }

    sub ($m, $k, $i = 0) {

        if ($k == 1) {

            my $L = divint($n, $m);

            foreach my $j ($i .. $factors_end) {
                my $q = $factors->[$j];
                last if ($q > $L);
                $callback->(mulint($m, $q));
            }

            return;
        }

        my $L = rootint(divint($n, $m), $k);

        foreach my $j ($i .. $factors_end) {
            my $q = $factors->[$j];
            last if ($q > $L);
            __SUB__->(mulint($m, $q), $k - 1, $j + $squarefree);
        }
    }->(1, $k);

    return;
}

sub isok($k, $n) {
    my $count = 0;
    almost_primes($k, $n, [grep { $_ > 1 } divisors($k)], sub ($t) {
        if ($t == $k) {
            ++$count;
        }
    }, 1);
    $count == $n;
}

sub a($n) {
    for(my $k = 2; ; ++$k) {
        if (isok($k, $n)) {
            return $k;
        }
    }
}

foreach my $n (2..100) {
    say "a($n) = ", a($n);
}

__END__
a(2) = 12
a(3) = 60
a(4) = 420
a(5) = 3456
a(6) = 60060
a(7) = 155520
a(8) = 1512000
a(9) = 13063680
a(10) = 169344000
