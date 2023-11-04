#!/usr/bin/perl

# Odd integers n such that Lucas V_{1, -1}(n) == 2 (mod n).

# Known terms:
#   1643, 387997, 174819237, 237040185477

# a(4) was found by Giovanni Resta on 02 October 2019.

# Indices of 2 in A213060.
# https://oeis.org/A213060

use 5.036;
use Math::GMPz;
use ntheory                qw(:all);
use Math::Prime::Util::GMP qw();

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    (substr($n, -1) & 1) || next;    # n must be odd

    #~ if ($n > ((~0) >> 1)) {
    #~ $n = Math::GMPz->new("$n");
    #~ }

    my $v = ($n > ~0) ? Math::Prime::Util::GMP::lucasvmod(1, -1, $n, $n) : lucasvmod(1, -1, $n, $n);

    if ($v eq '2') {
        say $n;
    }
}
