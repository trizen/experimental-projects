#!/usr/bin/perl

# a(n) is the largest n-digit pseudoprime (to base 2).
# https://oeis.org/A067845

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    my $len = length($n);

    next if $len > 40;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    if (exists $table{$len}) {
        next if ($table{$len} > $n);
    }

    if (is_pseudoprime($n, 2)) {
        $table{$len} //= $n;
        if ($n > $table{$len}) {
            $table{$len} = $n;
        }
    }
}

foreach my $len (sort { $a <=> $b } keys %table) {
    say "$len $table{$len}";
}
