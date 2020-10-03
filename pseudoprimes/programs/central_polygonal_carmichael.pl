#!/usr/bin/perl

# Carmichael numbers (A002997) that are central polygonal numbers (A002061).
# https://oeis.org/A303791

# Known terms:
#   5310721, 2278677961, 9593125081, 29859667201, 467593730289953281

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    $n = Math::GMPz->new($n);

    if (Math::GMPz::Rmpz_perfect_square_p(4*$n - 3) and is_carmichael($n)) {
        say $n;
    }
}
