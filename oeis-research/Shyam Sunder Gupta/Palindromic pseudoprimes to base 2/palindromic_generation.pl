#!/usr/bin/perl

# Palindromic pseudoprimes (base 2).
# https://oeis.org/A068445

# Known terms:
#   101101, 129921, 1837381, 127665878878566721, 1037998220228997301

use 5.020;
use strict;
use warnings;

use ntheory qw(is_pseudoprime is_prime);
use experimental qw(signatures);

my $count = 0;

# Observation: the next term cannot be even, therefore it must end with an odd digit.

#my $n = "31169999999999996113";    # the next term is greater than this
my $n = "114149999979999941411";

my @d = split(//, $n);

while (1) {

    my $l = $#d;
    my $i = (($l + 2) >> 1) - 1;

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
        @d     = (0) x (scalar(@d) + 1);
        $d[0]  = 1;
        $d[-1] = 1;
    }

    my $t = join('', @d);

    if (++$count % 1_000_000 == 0) {
        $count = 0;
        say "Testing: $t";
    }

    if (is_pseudoprime($t, 2) and !is_prime($t)) {
        die "Found new term: $t";
    }
}
