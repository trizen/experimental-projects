#!/usr/bin/perl

# a(n) is the smallest even number k such that k-1 and k+1 are both n-almost primes.
# https://oeis.org/A335667

# Known terms:
#   4, 34, 274, 2276, 8126, 184876, 446876, 18671876, 95234374, 1144976876, 6018359374, 281025390626, 2068291015624, 6254345703124

# Too slow...

use 5.036;
use ntheory qw(:all);

my $n = 12;

my $from = powint(2, $n);
my $upto = 2*$from;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n, $from, $upto);

    foreach my $i (0..$#{$arr}-2) {
        my $k = $arr->[$i];
        if ($k % 2) {
            my $t = $arr->[$i+1];
            $t = $arr->[$i+2] if ($t < $k+2);
            if ($t == $k+2) {
                printf("a(%s) = %s\n", $n, $k-1);
                exit;
            }
        }
    }

    $from = $upto-4;
    $upto = int(1.1*$from);
}
