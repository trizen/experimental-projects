#!/usr/bin/perl

# a(n) is the number of positive k (can be equal to n) such that A000005(n)/n = A000005(k)/k.
# https://oeis.org/A348172

# Conjecture: a(13011038208000) = 8:
#   1792 -> 13011038208000
#   2100 -> 15247310400000
#   2304 -> 16728477696000
#   2430 -> 17643316320000
#   2912 -> 21142937088000
#   3080 -> 22362721920000
#   3744 -> 27183776256000
#   3960 -> 28752071040000

# Program inspired by David A. Corneth's PARI program from A348172.

use 5.020;
use ntheory qw(:all);
use warnings;

use experimental qw(signatures);

sub a($n) {

    my $x = divisor_sum($n, 0);
    my $y = $n;

    my $g = gcd($x, $y);

    $x = divint($x, $g);
    $y = divint($y, $g);

    my $s = $y;
    my $res = 0;

    my $upto = 1+divint(vecprod(4,$y, $y), mulint($x, $x));

    my $t = 0;

    for(my $i = $s; $i <= $upto; $i = addint($i, $s)){
        $t = divint(mulint($x, $i), $y);
        if (divisor_sum($i, 0) == $t) {
            say ($i / $s, ' -> ', divint(mulint($i,$s), $y));
            ++$res;
        }
    }

    return $res;
}

#say a(3176523);
#say a(10598252544);
say a(13011038208000);
#say a(1191916494900613125);

__END__
func a(n) {

    var q = tau(n)/n
    var s = denominator(q)
    var res = 0

    for i in (s .. int(ceil(4 / q**2)) `by` s) {
        if (i.tau == q*i) {
             ++res
        }
    }

    return res
}

func b(n) {

    #var q = tau(n)/n
    var x = tau(n)
    var y = n

    var g = gcd(x, y)

    x /= g
    y /= g

    var s = y
    var res = 0

    for i in (s .. int(ceil(4 / (x/y)**2)) `by` s) {

        #var x1 = x*i
        #var y1 = y

        #var g1 = gcd(x1,y1)

        assert((x*i / s) / (y/s) -> is_int)

        if (i.tau == (x/y * i)) {
             #say [i / s, ((x*i / s) / (y / s))]
             ++res
        }
    }

    return res
}

#say a(3176523)
say b(3176523)
#say b(1191916494900613125)
