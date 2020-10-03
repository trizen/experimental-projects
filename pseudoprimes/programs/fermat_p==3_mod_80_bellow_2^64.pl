#!/usr/bin/perl

# Let p_1..p_k be distinct prime numbers and let n = p_1 * ... p_k.

# If the following conditions hold:
#   a) k == 1 (mod 4) or k == 3 (mod 4)
#   b) p_i == 3 (mod 80) for every i in {1..k}.
#   c) (p_i-1) | (n-1) for every i in {1..k}.
#   d) (p_i+1) | (n+1) for every i in {1..k}.

# Then n is a counter-example to Agrawal's conjecture.

# Carmichael number with all prime factors p == 3 (mod 80):
#   330468624532072027

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);
use IO::Uncompress::Bunzip2;

sub pretest ($n) {

    my $rem = $n % 80;
    ($rem == 27 or $rem == 3) || return;

    foreach my $p (5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 89, 97) {
        if ($n % $p == 0) {
            return;
        }
    }

    return 1;
}

sub isok($n) {
    pretest($n) || return;
    vecall { $_ % 80 == 3 } factor($n);
}

my $file = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/psps-below-2-to-64.txt.bz2";
my $z    = IO::Uncompress::Bunzip2->new($file);

while (defined(my $n = $z->getline())) {

    chomp $n;

    if (isok($n)) {
        say $n;
    }
}

__END__
51962615262396907
330468624532072027
2255490055253468347
18436227497407654507
