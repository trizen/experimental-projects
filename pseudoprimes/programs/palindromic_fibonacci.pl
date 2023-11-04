#!/usr/bin/perl

# Palindromic Fibonacci pseudoprimes.
# https://oeis.org/A212424

# Known terms:
#   323, 15251, 34943, 1625261, 14457475441

use 5.036;
use Math::GMPz;
use ntheory                qw(:all);
use Math::Prime::Util::GMP qw();

my %seen;

sub is_fibonacci_pseudoprime ($n) {
    Math::Prime::Util::GMP::lucasumod(1, -1, Math::Prime::Util::GMP::subint($n, Math::Prime::Util::GMP::kronecker(5, $n)), $n) eq '0';
}

my @terms;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    ($n eq reverse($n))          or next;
    is_fibonacci_pseudoprime($n) or next;

    next if $seen{$n}++;

    say $n;
    push @terms, $n;
}

@terms = sort { $a <=> $b } map { Math::GMPz->new($_) } @terms;

local $" = ', ';
say "\nKnown terms:\n\t@terms";
