#!/usr/bin/perl

use 5.014;
use Math::Prime::Util::GMP qw(sigma);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    if (sigma($n)/$n >= 1.7) {
        say $n;
    }
}
