#!/usr/bin/perl

# Daniel "Trizen" Șuteu and M. F. Hasler
# Date: 20 April 2018
# Edit: 23 April 2018
# https://github.com/trizen

# Find the first index of the odd prime number in the nth-order Fibonacci sequence.

# See also:
#   https://oeis.org/A302990

use 5.020;
use strict;
use warnings;

use Math::GMPz;

my $ONE = Math::GMPz->new(1);

use Math::Prime::Util::GMP qw(is_prob_prime);
use experimental qw(signatures);

sub nth_order_prime_fibonacci_index ($n = 2, $min = 0) {

    # Algorithm after M. F. Hasler from https://oeis.org/A302990
    my @a = map { $_ < $n ? ($ONE << $_) : $ONE } 1 .. ($n + 1);

    for (my $i = 2 * ($n += 1) - 2 ; ; ++$i) {

        my $t  = $i % $n;
        $a[$t] = ($a[$t-1] << 1) - $a[$t];

        if ($i >= $min and Math::GMPz::Rmpz_odd_p($a[$t])) {
            say "[", $n-1, "] Testing: $i";

            if (is_prob_prime($a[$t])) {
                say "\nFound: $t -> $i\n";
                return $i;
            }
        }
    }
}

# a(33) = 94246
# a(36) = 271172
# a(38) = ?
# a(39) = ?
# a(40) = 285
# a(41) > 178000
# a(42) = 558
# a(43) > 52842            ?
# a(44) = 19529         (found)
# a(45) > 44159            ?
# a(46) = 33369         (found)
# a(47) = 239
# a(48) = 6368
# a(49) > 30349            ?
# a(50) > 43705            ?
# a(51) > 35411            ?
# a(52) > 41127            ?
# a(53) = 2860
# a(54) = 2418
# a(55) > 40935            ?
# a(56) > 51184            ?
# a(57) > 45355            ?
# a(58) = 176
# a(59) = 18418         (found)
# a(60) = 1463
# a(61) = 122
# a(62) = 8755
# a(63) = 5118
# a(64) = 25089         (found)
# a(65) = 988
# a(66) = 333
# a(67) = 406
# a(68) > 39467            ?
# a(69) > 34229            ?
# a(70) = 1632
# a(71) > 35855            ?
# a(72) > 35039            ?
# a(73) > 37738            ?
# a(74) = 374
# a(75) > 49094            ?
# a(76) = 13704         (found)
# a(77) = 4991
# a(78) > 52454            ?
# a(79) > 42078            ?
# a(80) > 50624            ?
# a(81) > 113568           ?!
# a(82) > 43740            ?
# a(83) > 41662            ?
# a(84) > 37058            ?
# a(85) > 40676            ?
# a(86) = 347
# a(87) > 40039            ?
# a(88) > 39603            ?
# a(89) = 178           (found)
# a(90) > 40676            ?
# a(91) > 40111            ?
# a(92) = 1114
# a(93) = 187
# a(94) > 47023            ?
# a(95) > 38783            ?
# a(96) > 50341            ?
# a(97) > 41648            ?
# a(98) = 395
# a(99) > 50498            ?
# a(100) > 80294           ?

# a(38) > 134861
# a(39) > 105078
# a(41) > 178000       (M. F. Hasler)

# Searching for a(38) and a(39)
say nth_order_prime_fibonacci_index(38, 134861);
#say nth_order_prime_fibonacci_index(39, 105078);
