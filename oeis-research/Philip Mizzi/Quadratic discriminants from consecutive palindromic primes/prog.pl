#!/usr/bin/perl

# Positive integers in the form of the quadratic discriminant Δ = b^2 - 4ac, where a,b,c are consecutive palindromic primes
# https://oeis.org/A309487

# Apart from the first term, it appears that the values of "a" and "b" are given by A028990 and A028989, respectively

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub next_palindrome ($n) {

    my @d = split(//, $n);
    my $l = $#d;
    my $i = ((scalar(@d) + 1) >> 1) - 1;

    while ($i >= 0 and $d[$i] == 9) {
        $d[$i] = 0;
        $d[$l - $i] = 0;
        $i--;
    }

    if ($i >= 0) {
        $d[$i]++;
        $d[$l - $i] = $d[$i];
    }
    else {
        @d = (0) x (scalar(@d) + 1);
        $d[0]  = 1;
        $d[-1] = 1;
    }

    join('', @d);
}

sub next_prime_palindrome ($n) {        # next palindromic prime
    my $x = next_palindrome($n);

    while (!is_prime($x)) {
        $x = next_palindrome($x);
    }

    return $x;
}

#~ use Math::AnyNum qw(:overload);
#~ foreach my $a(929, 98689, 9989899, 999727999, 99999199999, 9999987899999, 999999787999999, 99999999299999999, 9999999992999999999, 999999999757999999999, 99999999997579999999999) {

    #~ my $b = next_prime_palindrome("$a");
    #~ my $c = next_prime_palindrome("$b");

    #~ $b = Math::AnyNum->new($b);
    #~ $c = Math::AnyNum->new($c);

    #~ say $b**2 - 4*$a*$c;
#~ }

#~ __END__

use Math::GMPz;
my $a = next_prime_palindrome(1);
my $b = next_prime_palindrome($a);
my $c = next_prime_palindrome($b);

while (1) {

    #if (Math::GMPz->new($b)**2 - 4 * Math::GMPz->new($a) * Math::GMPz->new($c) > 0) {

    if ($b*$b - 4*$a*$c > 0) {
        say (Math::GMPz->new($b)**2 - 4 * Math::GMPz->new($a)*$c, " -- ($a, $b, $c)");
    }

    ($a, $b, $c) = ($b, $c, next_prime_palindrome("$c"));
}

__END__
+---+-----------------+-------------------+-------------------+
| n |        a        |         b         |          c        |
+---+-----------------+-------------------+-------------------+
| 1 |              11 |               101 |               131 |
| 2 |             929 |             10301 |             10501 |
| 3 |           98689 |           1003001 |           1008001 |
| 4 |         9989899 |         100030001 |         100050001 |
| 5 |       999727999 |       10000500001 |       10000900001 |
| 6 |     99999199999 |     1000008000001 |     1000017100001 |
| 7 |   9999987899999 |   100000323000001 |   100000353000001 |
| 8 | 999999787999999 | 10000000500000001 | 10000001910000001 |
+---+-----------------+-------------------+-------------------+
