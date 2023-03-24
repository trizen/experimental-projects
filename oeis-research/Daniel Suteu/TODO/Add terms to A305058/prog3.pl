#!/usr/bin/perl

# https://oeis.org/A305058

my $s = "";

use ntheory ':all'; for (1..10**6) {

    #print "$_\n" if inverse_totient($_) == divisor_sum($_, 0)

    if (inverse_totient($_) == divisor_sum($_, 0)) {
        $s .= "$_, ";
        last if length($s) >= 260;
    }

    } # ~~~~

CORE::say $s;
