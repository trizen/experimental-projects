#!/usr/bin/perl

# Lucas pseudoprime reversible pairs.

# Known pair:
#   199017323 323710991

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub is_Bruckman_Lucas_pseudoprimes ($n) {
    (lucas_sequence($n, 1, -1, $n))[1] == 1;
}

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    my $m = reverse($n);

    if ($m < $n) {
        ($n, $m) = ($m, $n);
    }

    if (is_lucas_pseudoprime($m) and is_lucas_pseudoprime($n) and !is_prime($m) and !is_prime($n) and $n ne $m) {
        say($n, " ", $m) if !$seen{$n}++;
    }
}
