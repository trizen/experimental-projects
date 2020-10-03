#!/usr/bin/perl

# Palindromic Fibonacci pseudoprimes.
# https://oeis.org/A212424

# Known terms:
#   323, 15251, 34943, 1625261, 14457475441

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

my %seen;

sub is_fibonacci_pseudoprime($n) {
    (lucas_sequence($n, 1, -1, Math::GMPz->new($n) - kronecker($n, 5)))[0] == 0;
}

my @terms;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    ($n eq reverse($n)) or next;
    is_fibonacci_pseudoprime($n) or next;

    next if $seen{$n}++;

    say $n;
    push @terms, $n;
}

@terms = sort { $a <=> $b } map { Math::GMPz->new($_) } @terms;

local $" = ', ';
say "\nKnown terms:\n\t@terms";
