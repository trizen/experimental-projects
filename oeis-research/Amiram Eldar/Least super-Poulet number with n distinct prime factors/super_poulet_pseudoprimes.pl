#!/usr/bin/perl

# Least super-Poulet number (A050217) with n distinct prime factors.
# https://oeis.org/A328665

# Knwon terms:
#       341, 294409, 9972894583, 1264022137981459, 14054662152215842621

# Upper-bounds for larger values of n:
#   a(7)  <= 1842158622953082708177091
#   a(8)  <= 192463418472849397730107809253922101
#   a(9)  <= 1347320741392600160214289343906212762456021
#   a(10) <= 70865138168006643427403953978871929070133095474701
#   a(11) <= 3363391752747838578311772729701478698952546288306688208857
#   a(12) <= 132153369641266990823936945628293401491197666138621036175881960329
#   a(13) <= 9105096650335639994239038954861714246150666715328403635257215036295306537

use 5.020;
use warnings;
use experimental qw(signatures);

use IO::Handle;
use ntheory qw(forcomb forprimes divisors powmod);
use Math::Prime::Util::GMP;

sub super_poulet_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    forprimes {
        my $p = $_;
        foreach my $d (divisors($p - 1)) {

            #last if ($d == $p-1);

            if (powmod(2, $d, $p) == 1) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    } $limit;

    warn ":: Creating combinations...\n";

    #foreach my $arr (values %common_divisors) {
    while (my ($key, $arr) = each %common_divisors) {

        my $nf = 8;             # minimum number of prime factors
        next if @$arr < $nf;

        my $l = $#{$arr} + 1;

        foreach my $k ($nf .. $l) {
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n, $k);
            } $l, $k;
        }
    }
}

open my $fh, '>', 'psp_super_poulet_1.txt';

$fh->autoflush(1);

super_poulet_pseudoprimes(
    1e7,                     # limit of the largest prime factor
    sub ($n, $k) {
        if ($n > ~0) {       # report only numbers greater than 2^64
            warn "$k $n\n";
            say $fh "$k $n";
        }
    }
);

close $fh;
