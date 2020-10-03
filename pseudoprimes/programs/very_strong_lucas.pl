#!/usr/bin/perl

# Find strong Lucas pseudoprimes that are also extra-strong Lucas pseudoprimes.

# The first few terms, are:
#   5777, 10877, 75077, 100127, 113573, 155819, 161027, 162133, 189419, 231703, 430127, 635627, 851927, 1033997, 1106327, 1241099, 1256293, 1388903, 1697183, 2263127, 2435423

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

    next if ($n < ~0);

    is_pseudoprime($n, 2) && next;

    if (    is_strong_lucas_pseudoprime($n)
        and is_extra_strong_lucas_pseudoprime($n)
        and is_almost_extra_strong_lucas_pseudoprime($n)) {
        say $n if !$seen{$n}++;
    }
}

__END__
Some examples greater than 2^64:

18535627161040627067
18663879459398649467
18677450689252551197
18685239092291851463
18712889870502559547
18713136524626622473
18738423335243274893
18783115401546807457
18820639820672329597
18877890314405271983
19089885051126014533
19148640068904935077
19231457002307537293
19250202116550026357
19293074734601309717
19324718963259619963
19440950420527132067
19476146182748185757
