#!/usr/bin/perl

# Smallest strong pseudoprime to base 2 with n prime factors.
# https://oeis.org/A180065

# Known terms:
#   2047, 15841, 800605, 293609485, 10761055201, 5478598723585, 713808066913201, 90614118359482705, 5993318051893040401

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my %table;

while (my ($n, $value) = each %db) {

    my @factors = split(' ', $value);
    my $count   = scalar @factors;

    next if ($count <= 10);

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || next;

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    $table{$count} = $n;
    printf("a(%2d) <= %s\n", $count, $n);
}

dbmclose(%db);

say "\nFinal results:";

foreach my $k (sort { $a <=> $b } keys %table) {
    printf("a(%2d) <= %s\n", $k, $table{$k});
}

__END__
a(11) <= 40458813831093914176528685701
a(12) <= 3461315300911389965986555018529761
a(13) <= 1793888484612948579347804219906251
a(14) <= 11204126171093532395238176008628640001
a(15) <= 52763042375348388525807775606810431553349251
a(16) <= 8490206016886862443343349923062834577705405389801
a(17) <= 16466175808047026414728161638977648257386104008228485611
a(18) <= 5344281976789774350298352596501700430295430104885257558315750001
a(27) <= 7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109251
