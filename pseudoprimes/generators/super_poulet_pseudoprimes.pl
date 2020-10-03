#!/usr/bin/perl

# Generate Super-Poulet pseudoprimes to base 2, using prime factors bellow a certain limit.

use 5.020;
use warnings;
use experimental qw(signatures);

use IO::Handle;
use ntheory qw(forcomb forprimes divisors powmod znorder);
use Math::Prime::Util::GMP;

sub super_poulet_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    forprimes {
        my $p = $_;

        #if ($p % 24 == 1 or $p % 24 == 13) {
        #if ($p % 24 == 1) {
            my $z = znorder(2, $p);

            if (2*$z < $limit) {
            foreach my $d (divisors($p - 1)) {
                #if (powmod(2, $d, $p) == 1) {

                    if ($d % $z == 0) {
                        if ($p > 1e8) {
                            if (exists $common_divisors{$d}) {
                                push @{$common_divisors{$d}}, $p;
                            }
                        }
                        else {
                            push @{$common_divisors{$d}}, $p;
                        }
                    }

            #}
        }
        }
    } 3, $limit;

    warn ":: Creating combinations...\n";

    #foreach my $arr (values %common_divisors) {
    while (my ($key, $arr) = each %common_divisors) {

        my $nf = 5;                 # minimum number of prime factors
        #next if @$arr < $nf;

        my $l = scalar(@$arr);

        foreach my $k ($nf .. $l) {
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n);
            } $l, $k;
        }
    }
}

open my $fh, '>', 'super_poulet_numbers.txt';

#$fh->autoflush(1);

super_poulet_pseudoprimes(
    2e9,                            # limit of the largest prime factor
    sub ($n) {
        if ($n > ~0) {              # report only numbers greater than 2^64
            #warn "$n\n";
            say $fh $n;
        }
    }
);

close $fh;
