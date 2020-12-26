#!/usr/bin/perl

# Find Lucas-Carmichael numbers m such that gpf(m)-1 divides m-1, where gpf(n) is the greatest prime factor of n.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-lucas-carmichael.storable";
my $table         = retrieve($storable_file);

foreach my $key (sort { log($a) <=> log($b) } keys %$table) {

    my $n   = Math::GMPz->new($key);
    my $nm1 = $n - 1;

    if (Math::GMPz::Rmpz_divisible_p($nm1, Math::GMPz->new((split(' ', $table->{$key}))[-1]) - 1)) {
        say $n;
    }
}

__END__

# Large terms

7528378858876486724399
882521915656299454811036442239
13046104502838610619944087863962399
2234058365461416908764667377125935519
325364458600983576255744358844340424559
1743859916486942820437842382161666571759
1891105659381286213430254667759106591839
52708896904783934855815874404340752522079
30929869681595566326223026143547237768574058684159
157700896136019588908390412927666058161615233665199
180739644243274795122612378477503056744811039770137982278520020707039
