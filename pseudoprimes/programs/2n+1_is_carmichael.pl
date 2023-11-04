#!/usr/bin/perl

# Are there any Carmichael numbers n such that 2*n+1 is also a Carmichael number?

# See also:
#   https://oeis.org/A263403

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

#use Math::GMPz;
#use ntheory qw(:all);
use Math::Prime::Util::GMP qw(:all);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;

    my $n = (split(' ', $_))[-1];

    $n || next;
    $n > ~0 or next;

    #~ if ($n > ((~0) >> 2)) {
    #~ $n = Math::GMPz->new("$n");
    #~ }

    if (is_carmichael(addint(mulint(2, $n), 1))) {
        say "Candidate: $n";

        if (is_carmichael($n)) {
            die "Counter-example found: $n";
        }
    }
}
