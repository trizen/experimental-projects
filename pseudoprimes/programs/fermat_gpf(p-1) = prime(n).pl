#!/usr/bin/perl

# a(n) is the smallest Fermat pseudoprime to base 2 such that gpf(p-1) = prime(n) for all prime factors p of a(n).

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use ntheory    qw(:all);
use List::Util qw(uniq);

my %seen;
my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n > 1e15);
    is_pseudoprime($n, 2) or next;
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

my $prev = 0;
foreach my $p (sort { $a <=> $b } keys %table) {
    my $n = prime_count($p);
    last if ($n != $prev + 1);
    say "a($n) = $table{$p}";
    $prev = $n;
}
