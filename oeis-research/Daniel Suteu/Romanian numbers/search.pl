#!/usr/bin/perl

# a(n) is the smallest nonnegative number k such that the Romanian text of k contains n digits.

use utf8;
use 5.014;
use strict;
use warnings;

use Encode qw(decode_utf8 encode_utf8);
use Lingua::RO::Numbers qw(number_to_ro);

foreach my $n (3 .. 100) {
    foreach my $k (0 .. 1e11) {
        if (length(number_to_ro($k) =~ tr/, -//dr) == $n) {
            say "a($n) = $k -> ", encode_utf8(number_to_ro($k));
            last;
        }
    }
}

__DATA__
a(3) = 1 -> unu
a(4) = 0 -> zero
a(5) = 4 -> patru
a(6) = 8000 -> opt mii
a(7) = 60 -> șaizeci
a(8) = 20 -> douăzeci
a(9) = 40 -> patruzeci
a(10) = 11 -> unsprezece
a(11) = 12 -> doisprezece
a(12) = 13 -> treisprezece
a(13) = 15 -> cincisprezece
a(14) = 23 -> douăzeci și trei
a(15) = 24 -> douăzeci și patru
a(16) = 44 -> patruzeci și patru
a(17) = 113 -> o sută treisprezece
a(18) = 115 -> o sută cincisprezece
a(19) = 123 -> o sută douăzeci și trei
a(20) = 124 -> o sută douăzeci și patru
a(21) = 144 -> o sută patruzeci și patru
a(22) = 223 -> două sute douăzeci și trei
a(23) = 224 -> două sute douăzeci și patru
a(24) = 244 -> două sute patruzeci și patru
a(25) = 444 -> patru sute patruzeci și patru
a(26) = 1223 -> o mie două sute douăzeci și trei
a(27) = 1224 -> o mie două sute douăzeci și patru
a(28) = 1244 -> o mie două sute patruzeci și patru
a(29) = 1444 -> o mie patru sute patruzeci și patru
a(30) = 2224 -> două mii două sute douăzeci și patru
a(31) = 2244 -> două mii două sute patruzeci și patru
a(32) = 2444 -> două mii patru sute patruzeci și patru
a(33) = 4444 -> patru mii patru sute patruzeci și patru
a(34) = 11144 -> unsprezece mii o sută patruzeci și patru
a(35) = 11223 -> unsprezece mii două sute douăzeci și trei
a(36) = 11224 -> unsprezece mii două sute douăzeci și patru
a(37) = 11244 -> unsprezece mii două sute patruzeci și patru
a(38) = 11444 -> unsprezece mii patru sute patruzeci și patru
a(39) = 12444 -> doisprezece mii patru sute patruzeci și patru
a(40) = 13444 -> treisprezece mii patru sute patruzeci și patru
a(41) = 15444 -> cincisprezece mii patru sute patruzeci și patru
a(42) = 21244 -> douăzeci și unu de mii două sute patruzeci și patru
a(43) = 21444 -> douăzeci și unu de mii patru sute patruzeci și patru
a(44) = 22444 -> douăzeci și două de mii patru sute patruzeci și patru
a(45) = 24444 -> douăzeci și patru de mii patru sute patruzeci și patru
a(46) = 44444 -> patruzeci și patru de mii patru sute patruzeci și patru
a(47) = 121244 -> o sută douăzeci și unu de mii două sute patruzeci și patru
a(48) = 121444 -> o sută douăzeci și unu de mii patru sute patruzeci și patru
a(49) = 122444 -> o sută douăzeci și două de mii patru sute patruzeci și patru
a(50) = 124444 -> o sută douăzeci și patru de mii patru sute patruzeci și patru
a(51) = 144444 -> o sută patruzeci și patru de mii patru sute patruzeci și patru
a(52) = 222444 -> două sute douăzeci și două de mii patru sute patruzeci și patru
a(53) = 224444 -> două sute douăzeci și patru de mii patru sute patruzeci și patru
a(54) = 244444 -> două sute patruzeci și patru de mii patru sute patruzeci și patru
a(55) = 444444 -> patru sute patruzeci și patru de mii patru sute patruzeci și patru
a(56) = 1121444 -> un milion o sută douăzeci și unu de mii patru sute patruzeci și patru
a(57) = 1122444 -> un milion o sută douăzeci și două de mii patru sute patruzeci și patru
a(58) = 1124444 -> un milion o sută douăzeci și patru de mii patru sute patruzeci și patru
a(59) = 1144444 -> un milion o sută patruzeci și patru de mii patru sute patruzeci și patru
a(60) = 1222444 -> un milion două sute douăzeci și două de mii patru sute patruzeci și patru
a(61) = 1224444 -> un milion două sute douăzeci și patru de mii patru sute patruzeci și patru
a(62) = 1244444 -> un milion două sute patruzeci și patru de mii patru sute patruzeci și patru
a(63) = 1444444 -> un milion patru sute patruzeci și patru de mii patru sute patruzeci și patru
a(64) = 2222444 -> două milioane două sute douăzeci și două de mii patru sute patruzeci și patru
a(65) = 2224444 -> două milioane două sute douăzeci și patru de mii patru sute patruzeci și patru
