#!/usr/bin/perl

# Primes p such that the greatest common divisor of 2^p+1 and 3^p+1 is composite.
# https://oeis.org/A349722

# Known terms:
#   2243399, 2334547, 2743723, 3932207

# More terms (found with this program -- with possible gaps between terms):
#   2243399, 2334547, 2743723, 3932207, 4623107, 4716343, 5482423, 5993411, 7156769, 8795167, 9026987, 9608843, 9923209, 10451599, 11362123, 12547307, 13426667, 14882383, 17458943, 18117991, 18308443, 18467203, 18756191, 19418123, 19811503, 20572729, 20968427, 21216751, 21772811, 23621723, 24192587, 26394847, 27517667, 27765443, 27795583, 28501727, 29222183, 29438107, 30206327, 30397363, 31949941, 32235067, 32416823, 33035027, 33570347, 33634927, 33705391, 34081471, 36609787, 37819813, 40210147, 40296163, 40475251, 40735693, 41702027, 42277927, 42531451, 42769451, 42894197, 43338203, 48141287, 48313849, 48419047, 50076109, 51784543, 52853987, 54469643, 55384831, 55736743, 56244467, 56535043, 57759607, 58821907, 58939411, 59106881, 60091763, 60110123, 60192367, 60339131, 60690691, 63267007, 63339803, 64726751, 66938323, 67103711, 68021699, 68498827, 68834387, 70097743, 72720587, 73332047, 74954387, 75352567, 75674563, 76213603, 77343943, 77666063, 78093263, 79452463, 79764823, 80295769, 80834599, 81647551, 82346087, 82622027, 84482327, 85263727, 85608067, 88300763, 89120807, 90118229, 90530347, 93888611, 93983023, 96233843, 98936647, 99492167, 102265307, 104468867, 109002151, 111510823, 112353203, 114383551, 114565127, 114874883, 115580323, 118369543, 120632027, 121397971, 124515563, 125686711, 126519643, 129564467, 130665427, 131309467, 131891323, 132186007, 132360427, 135864923, 136972967, 138852251, 139707367, 140145287, 141264083, 142496323, 142943687, 143384383, 146360843, 147622367, 151675163, 152898667, 152995267, 153281963, 154214611, 154444307, 154926727, 156729943, 158623183, 160638323, 160992131, 161142203, 162781007, 162885091, 163266281, 163499669, 164070143, 165541109, 166784687, 169785983, 171110651, 171984467, 172444507, 172546637, 174615227, 176728907, 177592847, 178191551, 179320951, 182170763, 182259923, 184151167, 185394563, 185783231, 186397067, 187692467, 187732243, 187863647, 188187347, 188202607, 190656463, 191012651, 191870051, 193993571, 194113091, 194367827, 197536687, 199126303, 200061731, 200218283, 200550331, 200843351, 201504727, 202034291, 202333567, 203548967, 204541607, 207325543, 208423123

# Fun facts: let g = gcd(2^p+1, 3^p+1)
#   * g must be a strong pseudoprime to base 2 and base 3.
#   * the multiplicative order of g modulo 2 and modulo 3 equals 2*p
#       i.e.: znorder(Mod(2, g)) == znorder(Mod(3, g)) == 2*p
#   * using the list of base-2 Fermat pseudoprimes below 2^64, should be possible to find some of the terms

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

my $limit = 78>>1;
my $count = 0;

local $| = 1;

forprimes {

    my $p = $_;
    #say "Testing: $p" if (++$count % 10000 == 0);

    #for k in (1 .. limit) {
    foreach my $k (1..$limit) {
        my $t = (2*$k*$p + 1);
        if (powmod(2, $p, $t) == $t-1) {
            foreach my $x ($k+1 .. $limit) {
                my $u = (2*$x*$p + 1);
                my $w = mulint($u, $t);
                my $r = subint($w, 1);
                if (powmod(3, $p, $w) == $r) {
                    if (powmod(2, $p, $w) == $r) {
                        print($p, ", ");
                        last;
                        #say "Jackpot: [$u, $t] = $w for p = $p";
                    }
                }
            }
        }
    }

} 2243399, 1e12;