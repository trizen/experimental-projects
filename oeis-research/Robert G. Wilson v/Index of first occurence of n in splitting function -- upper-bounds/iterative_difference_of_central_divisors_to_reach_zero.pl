#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 22 March 2019
# https://github.com/trizen

# Let f(n) be the difference between the least divisor of n that is >= sqrt(n) and the greatest divisor of n that is <= sqrt(n).
# Let g(n) be the number of iterations of f(n) required to reach zero.

# Then a(n) is the smallest integer k of the form x*(x + a(n-1)), such that g(k) = n, for some positive integer x, with a(0) = 0.

# This sequence provides upper-bounds for:
#   https://oeis.org/A324921

# Example:
#   a(30) = 940055257114567466733218694 = 42 * (42 + 205 * (205 + 68 * (68 + 9 * (9 + 56 * (56 + 53 * (53 + 14 * (14 + 5 * (5 + 34 * (34 + 73 * (73 + 6 * (6 + 43 * (43 + 8 * (8 + 3 * (3 + 10 * (10 + 9 * (9 + 4 * (4 + 7 * (7 + 12 * (12 + 5 * (5 + 2 * (2 + 1 * (1 + 2 * (2 + 3 * (3 + 2 * (2 + 1 * (1 + 2 * (2 + 1 * (1 + 1 * (1 + 1 * (1 + 0))))))))))))))))))))))))))))))

# OEIS sequences:
#   https://oeis.org/A324921 -- Index of first occurrence of n in A324920.
#   https://oeis.org/A056737 -- Minimum nonnegative integer m such that n = k*(k+m) for some positive integer k.
#   https://oeis.org/A324920 -- a(n) is the number of iterations of the integer splitting function (A056737) necessary to reach zero.

# a(n) is the smallest integer k of the form k = x*(x + a(n-1)), such that A324920(k) = n, for some positive integer x, with a(0) = 0.
# https://oeis.org/A307034

use 5.020;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

sub f($n) {
    if (is_square($n)) {
        0;
    }
    else {
        my @d = divisors($n);
        Math::GMPz->new($d[(1 + $#d) >> 1]) - $d[($#d) >> 1];
    }
}

sub g($n) {

    my $t     = f($n);
    my $count = 1;

    while ($t) {
        $t = f($t);
        ++$count;
    }

    $count;
}

my $n = Math::GMPz->new(0);

for my $j (1 .. 30) {

    for (my $x = 1 ; ; ++$x) {

        my $k = $x * ($n + $x);
        my $t = g($k);

        if ($t == $j) {
            $n = $k;
            say "a($j) = $k";
            last;
        }
    }
}

__END__
a(1)  = 1
a(2)  = 2
a(3)  = 3
a(4)  = 10
a(5)  = 11
a(6)  = 26
a(7)  = 87
a(8)  = 178
a(9)  = 179
a(10) = 362
a(11) = 1835
a(12) = 22164
a(13) = 155197
a(14) = 620804
a(15) = 5587317
a(16) = 55873270
a(17) = 167619819
a(18) = 1340958616
a(19) = 57661222337
a(20) = 345967334058
a(21) = 25255615391563
a(22) = 858690923314298
a(23) = 4293454616571515
a(24) = 60108364632001406
a(25) = 3185743325496077327
a(26) = 178401626227780333448
a(27) = 1605614636050023001113
a(28) = 109181795251401564080308
a(29) = 22382268026537320636505165
a(30) = 940055257114567466733218694
a(31) = 102466023025487853873920849527
a(32) = 3688776828917562739461150584268
a(33) = 217637832906136201628207884475293
a(34) = 10011340313682265274897562685865594
a(35) = 830941246035628017816497702926851191
a(36) = 74784712143206521603484793263416615290
a(37) = 9946366715046467373263477504034409851259
a(38) = 1233349472665761954284671210500266821571492
a(39) = 11100145253991857588562040894502401394143509
a(40) = 155402033555886006239868572523033619518009322
a(41) = 6060679308679554243354874328398311161202365079
a(42) = 12121358617359108486709748656796622322404730162
a(43) = 1321228089292142825051362603590831833142115599539
a(44) = 295955092001439992811505223204346330623833894346912
a(45) = 3255506012015839920926557455247809636862172837816153
a(46) = 97665180360475197627796723657434289105865185134485490
a(47) = 8887531412803242984129501852826520308633731847238187871
a(48) = 106650376953638915809554022233918243703604782166858254596
a(49) = 23143131798939644730673222824760258883682237730208241294421
a(50) = 2036595598306688736299243608578902781764036920258325233916792
