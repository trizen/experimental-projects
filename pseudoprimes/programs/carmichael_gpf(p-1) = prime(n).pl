#!/usr/bin/perl

# a(n) is the smallest Carmichael number such that gpf(p-1) = prime(n) for all prime factors p of a(n).

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use ntheory qw(:all);
use List::Util qw(uniq);

my %seen;
my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n > 1e15);
    is_carmichael($n) or next;
    next if $seen{$n}++;

    my @gpf = uniq(map { (factor($_ - 1))[-1] } factor($n));

    if (@gpf == 1) {
        my $p = $gpf[0];
        $table{$p} //= $n;
        if ($n < $table{$p}) {
            $table{$p} = $n;
        }
    }
}

foreach my $p (sort { $a <=> $b } keys %table) {
    my $n = prime_count($p);
    say "a($n) = $table{$p}";
}
