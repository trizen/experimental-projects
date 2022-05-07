#!/usr/bin/perl

# Least overpseudoprime to base 2 (A141232) with n distinct prime factors.

# First few terms:
#   2047, 13421773

# See also:
#   https://oeis.org/A141232

# Inspired by:
#   https://oeis.org/A328665

# a(2) = 2047
# a(3) = 13421773

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Sidef qw(is_over_psp);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-superpsp.storable";
my $numbers       = retrieve($storable_file);

my %table;

foreach my $n (sort { log($a) <=> log($b) } keys %$numbers) {

    my @factors = split(' ', $numbers->{$n});
    my $count   = scalar @factors;

    next if ($count < 4);

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    is_over_psp($n) || next;

    $table{$count} = $n;
    printf("a(%2d) <= %s\n", $count, $n);
}

__END__
a( 4) <= 19062476538262521877
a( 5) <= 1376414970248942474729
a( 6) <= 48663264978548104646392577273
a( 7) <= 294413417279041274238472403168164964689
a( 8) <= 98117433931341406381352476618801951316878459720486433149
a( 9) <= 1252977736815195675988249271013258909221812482895905512953752551821

# Old upper-bounds:

a( 9) <= 30105828357081097677279040212365467806880753531270764452579144337486612371603521
