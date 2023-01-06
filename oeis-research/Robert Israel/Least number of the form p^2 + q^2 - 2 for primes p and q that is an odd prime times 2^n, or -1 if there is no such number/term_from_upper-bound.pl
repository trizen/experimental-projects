#!/usr/bin/perl

# a(n) is the least number of the form p^2 + q^2 - 2 for primes p and q that is an odd prime times 2^n, or -1 if there is no such number
# https://oeis.org/A359492

# Known terms:
#   11, 6, -1, 56, 48, 96, 192, 384, 2816, 1536, 109568, 10582016, 12288, 7429922816, 64176128, 4318724096, 196608, 60486975488, 9388028592128

# Observation:
#    most solutions have the form 3^2 + q^2.

use 5.020;
use warnings;

use ntheory qw(:all);

my $n = 21;
my $k = 896029329195008;

say "a($n) <= $k";

for(my $p = 3; ; $p = next_prime($p)) {

    last if (2*$p*$p > $k);

    say "Checking: p = $p";

    my $p2 = $p*$p;

    for (my $q = $p; ; $q = next_prime($q)) {

        my $t = subint(addint($q*$q, $p2), 2);

        last if ($t > $k);

        my $v = valuation($t, 2);
        my $r = $t >> $v;

        if ($v == $n and is_prime($r)) {
            if ($t < $k) {
                $k = $t;
                say "a($n) <= $k";
            }
        }

    }
}

say "a($n) = $k";

__END__
a(0) <= 11
a(3) <= 56
a(4) <= 176
a(5) <= 1376
a(6) <= 1856
a(8) <= 2816
a(7) <= 19328
a(10) <= 109568
a(9) <= 344576
a(11) <= 10582016
a(14) <= 64176128
a(12) <= 932630528
a(15) <= 4318724096
a(13) <= 7429922816
a(16) <= 32415481856
a(17) <= 60486975488
a(18) <= 9388028592128
a(20) <= 214058289594368
a(19) <= 849566088298496
a(21) <= 896029329195008
a(22) <= 10228945815339008
a(24) <= 54409680373415936
a(23) <= 188039754665689088
a(25) <= 246561971023904768
a(26) <= 966464636658384896
a(30) <= 1278798840983453696
