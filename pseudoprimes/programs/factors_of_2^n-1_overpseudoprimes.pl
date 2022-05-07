#!/usr/bin/perl

# Find overpseudoprimes with small znorder z. Such pseudoprimes divide 2^z - 1.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-superpsp.storable";
my $numbers       = retrieve($storable_file);

sub is_over_pseudoprime_fast ($n, $factors) {

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || return;

    my $gcd = Math::Prime::Util::GMP::gcd(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);

    Math::Prime::Util::GMP::powmod(2, $gcd, $n) eq '1'
      or return;

    my $prev;

    foreach my $p (@$factors) {

        if (defined($prev)) {
            if ($p < ~0) {
                Math::Prime::Util::powmod(2, $prev, $p) == 1 or return;
            }
            else {
                Math::Prime::Util::GMP::powmod(2, $prev, $p) eq '1' or return;
            }
        }

        my $zn = znorder(2, $p);

        if ($zn > 1e6) {
            return;
        }

        if (defined($prev)) {
            $zn == $prev or return;
        }
        else {
            $prev = $zn;
        }
    }

    return $prev;
}

my %table;

foreach my $n (sort { log($a) <=> log($b) } keys %$numbers) {

    length($n) > 40 or next;

    my @factors = split(' ', $numbers->{$n});
    my $count   = scalar @factors;

    length($factors[0]) <= 40 or next;

    my $z = is_over_pseudoprime_fast($n, \@factors) // next;

    say "2^$z-1 = $n";
}
