#!/usr/bin/perl

# Thomas Ordowski, Oct 17 2015:
#   Are there Carmichael numbers k such that the odd part of k-1 is a Carmichael number?

# https://oeis.org/A263403

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

#use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;

sub odd_part ($n) {
    #$n >> valuation($n, 2);
    rshiftint($n, Math::Prime::Util::GMP::valuation($n, 2));
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n > ~0 or next;

    #~ if ($n > ((~0) >> 1)) {
        #~ $n = Math::GMPz->new("$n");
    #~ }

    if (Math::Prime::Util::GMP::is_carmichael(odd_part(Math::Prime::Util::GMP::subint($n, 1)))) {
        say "Candidate: $n";

        if (Math::Prime::Util::GMP::is_carmichael($n)) {
            die "Counter-example found: $n";
        }
    }
}
