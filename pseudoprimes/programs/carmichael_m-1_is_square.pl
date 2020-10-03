#!/usr/bin/perl

# Carmichael numbers n such that n-1 is a square.
# https://oeis.org/A265285

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    if (is_square($n - 1) and is_carmichael($n)) {
        say $n if !$seen{$n}++;
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
