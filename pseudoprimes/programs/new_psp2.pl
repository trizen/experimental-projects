#!/usr/bin/perl

# Generate new Fermat pseudoprimes to base 2 from other pseudoprimes x, of the form 2x+1 or (x-1)/2.

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
    my $key = "$n";

    if ($n > ((~0) >> 2)) {
        $n = Math::GMPz->new($n);
    }

    $seen{$key} = $n;
}

my @values = sort { $a <=> $b } values %seen;

foreach my $n (@values) {

    my $x = ($n << 1) + 1;
    my $y = ($n - 1) >> 1;

    if (is_pseudoprime($x, 2) and !is_prime($x)) {
        say $x if not exists $seen{$x};
    }

    if (is_pseudoprime($y, 2) and !is_prime($y)) {
        say $y if not exists $seen{$y};
    }
}
