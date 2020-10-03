#!/usr/bin/perl

# Palindromic pseudoprimes in base n.

# See also:
#   https://oeis.org/A210454
#   https://oeis.org/A068445

# Carmichael numbers that are palindromic in base 2:
#   561, 1105, 278545, 67371265

# Fermat pseudoprimes to base 2 that are palindromic in base 2 (includes the Cipolla pseudoprimes to base 2 (Cf. A210454)):
#   341, 561, 645, 1105, 2047, 4369, 4681, 5461, 8481, 16705, 33153, 266305, 278545, 526593, 1052929, 1082401, 1398101, 2113665, 2162721, 2290641, 4259905, 6242685, 7674967, 8388607, 16843009, 17895697, 22369621, 34603041, 67371265, 268505089, 280885153, 285212689, 536870911, 1073823745, 1090519105, 1227133513, 4294967297, 4648341841, 5205132505, 5726623061, ...

# Fermat pseudoprimes to base 2 that are palindromic in base 3:
#   32034955681, 317733228541, 24400124965189

# Fermat pseudoprimes to base 2 that are palindromic in base 5:
#   399001, 290643601

# Fermat pseudoprimes to base 2 that are palindromic in base 6:
#   4371, 13741, 46657, 52633, 60514129, 65241793, 216797601, 404514145, 13148013529, 113062555201

# Fermat pseudoprimes to base 2 that are palindromic in base 7:
#   (none known)

# Fermat pseudoprimes to base 2 that are palindromic in base 9:
#   78526729, 206304961, 207487561, 309087848161, 317733228541

# Fermat pseudoprimes to base 2 that are palindromic in base 10:
#   101101, 129921, 1837381, 127665878878566721, 1037998220228997301

# Fermat pseudoprimes to base 2 that are palindromic in base 11:
#   516764063, 117933555719486641

# Fermat pseudoprimes to base 2 that are palindromic in base 12:
#   1729, 2821, 31609, 34945, 314821, 4038673, 54651961, 1122688690201

# Fermat pseudoprimes to base 2 that are palindromic in base 13:
#   147196437961

# Fermat pseudoprimes to base 2 that are palindromic in base 14:
#   2701, 72885, 1701016801

# Fermat pseudoprimes to base 2 that are palindromic in base 15:
#   3594300841

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

my $n    = '1';     # start from this palindrome
my $base = 2;

my @d = todigits($n, $base);

while (1) {

    my $l = $#d;
    my $i = ((scalar(@d) + 1) >> 1) - 1;

    while ($i >= 0 and $d[$i] == ($base - 1)) {
        $d[$i] = 0;
        $d[$l - $i] = 0;
        $i--;
    }

    if ($i >= 0) {
        $d[$i]++;
        $d[$l - $i] = $d[$i];
    }
    else {
        @d     = (0) x (scalar(@d) + 1);
        $d[0]  = 1;
        $d[-1] = 1;
    }

    my $t = ($base <= 10 ? fromdigits(join('', @d), $base) : fromdigits(\@d, $base));

    # Terms must be odd (skip otherwise)
    next if substr($t, -1) % 2 == 0;

    if (is_pseudoprime($t, 2) and !is_prime($t)) {
    #if(is_carmichael($t)) {
        say $t;
    }
}
