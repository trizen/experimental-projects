#!/usr/bin/perl

# Carmichael numbers (A002997) that are central polygonal numbers (A002061).
# https://oeis.org/A303791

# Known terms:
#   5310721, 2278677961, 9593125081, 29859667201, 467593730289953281

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my $z = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    Math::GMPz::Rmpz_set_str($z, $n, 10);
    Math::GMPz::Rmpz_mul_2exp($z, $z, 2);
    Math::GMPz::Rmpz_sub_ui($z, $z, 3);

    if (Math::GMPz::Rmpz_perfect_square_p($z) and is_carmichael($n)) {
        say $n;
    }
}
