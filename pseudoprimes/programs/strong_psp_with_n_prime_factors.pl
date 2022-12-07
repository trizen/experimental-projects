#!/usr/bin/perl

# Smallest strong pseudoprime to base 2 with n prime factors.
# https://oeis.org/A180065

# Known terms:
#   2047, 15841, 800605, 293609485, 10761055201, 5478598723585, 713808066913201, 90614118359482705, 5993318051893040401

# New terms found (24 September 2022):
#   a(11) = 24325630440506854886701
#   a(12) = 27146803388402594456683201
#   a(13) = 4365221464536367089854499301
#   a(14) = 2162223198751674481689868383601
#   a(15) = 548097717006566233800428685318301

# It took 7 hours and 25 minutes to find a(14).
# It took 7 hours and 26 minutes to find a(15).

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

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || next;

    $table{$count} = $n;
    printf("a(%2d) <= %s\n", $count, $n);
}

dbmclose(%db);

say "\nFinal results:";

foreach my $k (sort { $a <=> $b } keys %table) {
    printf("a(%2d) <= %s\n", $k, $table{$k});
}

__END__
a(11) <= 24325630440506854886701
a(12) <= 27146803388402594456683201
a(13) <= 4365221464536367089854499301
a(14) <= 2162223198751674481689868383601
a(15) <= 548097717006566233800428685318301
a(16) <= 431963846549014459308449974667236801
a(17) <= 1554352698725568399952746943189797571201
a(18) <= 2095080420396817592160909089382002325129301
a(19) <= 1085479319509324324097609405158976672897141701
a(20) <= 104401072161516455118453426514933161641777596968579758315153304367262944853939848054942769476777571455422601
a(27) <= 7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109251
