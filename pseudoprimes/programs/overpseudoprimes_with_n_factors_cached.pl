#!/usr/bin/perl

# Least overpseudoprime to base 2 (A141232) with n distinct prime factors.
# https://oeis.org/A353409

# First few terms:
#   2047, 13421773, 14073748835533

# See also:
#   https://oeis.org/A141232

# Inspired by:
#   https://oeis.org/A328665

# a(1) = 1194649        (??)
# a(2) = 2047
# a(3) = 13421773
# a(4) = 14073748835533

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_over_psp);
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

        if (defined($prev)) {
            $zn == $prev or return;
        }
        else {
            $prev = $zn;
        }
    }

    return 1;
}

my %table;

foreach my $n (sort { log($a) <=> log($b) } keys %$numbers) {

    my @factors = split(' ', $numbers->{$n});
    my $count   = scalar @factors;

    next if ($count <= 4);

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    #is_over_psp($n) || next;
    is_over_pseudoprime_fast($n, \@factors) || next;

    $table{$count} = $n;
    printf("a(%2d) <= %s\n", $count, $n);
}

__END__
a( 5) <= 1376414970248942474729
a( 6) <= 48663264978548104646392577273
a( 7) <= 294413417279041274238472403168164964689
a( 8) <= 98117433931341406381352476618801951316878459720486433149
a( 9) <= 1252977736815195675988249271013258909221812482895905512953752551821
a(10) <= 179956551781727855312421540307439274354787884732076665324030222904473503226859514812761627444155634285996836425340835804928330642219771987560340607234606554205389

# Old upper-bounds:

a( 9) <= 30105828357081097677279040212365467806880753531270764452579144337486612371603521
