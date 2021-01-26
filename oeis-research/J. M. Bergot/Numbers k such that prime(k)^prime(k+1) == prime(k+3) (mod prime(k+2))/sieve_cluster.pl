#!/usr/bin/perl

# Prime cluster sieving for:
#   https://oeis.org/A340876
#   https://oeis.org/A340868

use 5.014;
use ntheory qw(:all);

foreach my $value (

    [6, 12, 14],
    [2, 12, 18],
    [16, 22, 28],
    [30, 52, 54],
    [44, 50, 56],
    [10, 24, 30],

#~ [18, 24, 26],
#~ [6, 14, 20],
#~ [64, 118, 126],
#~ [12, 24, 34],

) {

    my @arr = @$value;
    say "# Sieving with (@arr)";

    foreach my $p (sieve_prime_cluster(2, 1e11, @arr)) {

        #if ($p > 59782603009) {
        if ($p > 17674729) {

            my $q = $p+$arr[0];
            my $r = $p+$arr[1];
            my $s = $p+$arr[2];

            if (powmod($p, $q, $r) == ($s % $r)) {
            #if (powmod($p, $q, $s) == $r) {
                say "$p -> ", prime_count($p);
            }
        }
    }
}
