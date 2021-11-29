#!/usr/bin/perl

# Lesser of 2 consecutive Fermat pseudoprimes to base 2 with no prime numbers in between them.
# https://oeis.org/A335326

# Known terms:
#    4369, 13741, 31609, 6973057, 208969201

# No more terms < 2^64.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use IO::Uncompress::UnZstd;

my $file = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/psps-below-2-to-64.txt.zst";
my $z    = IO::Uncompress::UnZstd->new($file);

chomp(my $x = $z->getline());
chomp(my $y = $z->getline());

while (1) {

    if (next_prime($x) > $y) {
        say $x;
    }

    chomp(my $t = $z->getline() // last);

    ($x, $y) = ($y, $t);
}

__END__
4369
13741
31609
6973057
208969201
