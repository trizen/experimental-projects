#!/usr/bin/perl


use 5.014;

use ntheory qw(:all);
use experimental qw(signatures);

sub chernick_carmichael_factors ($n, $m) {
    (6*$m + 1, 12*$m + 1, (map { (1 << $_) * 9*$m + 1 } 1 .. $n-2));
}


say join(', ', chernick_carmichael_factors(12, 87711772697600));
say join(', ', chernick_carmichael_factors(12, 87730306287360));

my $f = 12;

my $factor1 = (1<<($f-2)) * 9;
my $factor2 = (1<<($f-3)) * 9;
my $factor3 = (1<<($f-4)) * 9;
my $factor4 = (1<<($f-5)) * 9;

my $multiplier = (1<<($f-4));

local $| = 1;
foreach my $k(68500000000..1e12) {

    my $n = $multiplier*$k;
    if (is_prime(6*$n+1) and is_prime(12*$n+1) and is_prime(18*$n+1) and is_prime($factor1*$n+1) and is_prime($factor2*$n+1)

    and is_prime($factor3*$n+1)
    and is_prime($factor4*$n+1)

    ) {
        #say $n;
        #print($n*$factor + 1, ", " );
        #print($n, ", ");
        say "$n -> ", join(', ', factor($k));
    }
}
