#!/usr/bin/perl

# Generate Super-Poulet pseudoprimes to base 2, using prime factors bellow a certain limit.

use 5.020;
use warnings;
use experimental qw(signatures);

#use IO::Handle;
use List::Util qw(uniq);
use ntheory qw(:all);
use Math::Prime::Util::GMP;

sub super_poulet_pseudoprimes ($primes, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    my %seen;

    foreach my $p (@$primes) {

        modint($p, 8) == 3     or next;
        kronecker(5, $p) == -1 or next;

        next if $seen{$p}++;

        $p >= 3 or next;

        #$p < ~0 or next;    # ignore too large primes

        my $z = znorder(2, $p);

        foreach my $d (divisors(subint($p, 1))) {
            if (modint($d, $z) == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }

        #~ foreach my $d (divisors(subint($p, kronecker(5, $p)))) {
            #~ if (lucasumod(1, -1, $d, $p) == 0) {
            #~ #if ($d > 1 and lucasvmod(1, -1, $d, $p) == 1) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    }

    warn ":: Creating combinations...\n";

    #foreach my $arr (values %common_divisors) {
    while (my ($key, $arr) = each %common_divisors) {

        my $nf = 3;    # minimum number of prime factors
        $arr = [uniq(@$arr)];
        my $l = scalar(@$arr);

        say "$l -- $nf -- @$arr" if ($l > 1);

        #foreach my $k ($nf .. $l) {
        for (my $k = $nf ; $k <= $l ; $k += 2) {
            forcomb {
                $callback->(Math::Prime::Util::GMP::vecprod(@{$arr}[@_]));
            }
            $l, $k;
        }
    }
}

my @primes;

while (<>) {
    next if /^#/;
    /\d/ or next;
    my $p = (split(' ', $_))[-1];
    push @primes, $p;
}

open my $fh, '>', 'super_poulet_numbers.txt';

#$fh->autoflush(1);

super_poulet_pseudoprimes(
    \@primes,
    sub ($n) {
        if ($n > ~0) {    # report only numbers greater than 2^64
            warn "$n\n";
            say $fh $n;
        }
    }
);

close $fh;
