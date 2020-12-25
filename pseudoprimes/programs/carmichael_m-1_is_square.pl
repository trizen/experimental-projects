#!/usr/bin/perl

# Carmichael numbers n such that n-1 is a square.
# https://oeis.org/A265285

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
    Math::GMPz::Rmpz_sub_ui($z, $z, 1);

    if (Math::GMPz::Rmpz_perfect_square_p($z) and is_carmichael($n)) {
        say $n;
    }
}

__END__
46657
2433601
67371265
351596817937
422240040001
18677955240001
458631349862401
286245437364810001
20717489165917230086401
