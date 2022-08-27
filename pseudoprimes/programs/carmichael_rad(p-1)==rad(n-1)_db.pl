#!/usr/bin/perl

# Squarefree composite numbers m such that rad(p-1) = rad(m-1) for every prime p dividing m.
# https://oeis.org/A306479

# First few terms:
#   1729, 46657, 1525781251

# Additional terms (with possible gaps):
#   763546828801, 6031047559681, 184597450297471, 732785991945841, 18641350656000001, 55212580317094201

# See also:
#   https://www.primepuzzles.net/puzzles/puzz_969.htm

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use POSIX qw(ULONG_MAX);

use Math::GMPz;
use Math::GMPq;
use Math::MPFR;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util qw(uniq);

use POSIX qw(ULONG_MAX);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_smooth_over_prod ($n, $k) {

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_set($t, $n);
    Math::GMPz::Rmpz_gcd($g, $t, $k);

    while (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_remove($t, $t, $g);
        return 1 if Math::GMPz::Rmpz_cmp_ui($t, 1) == 0;
        Math::GMPz::Rmpz_gcd($g, $t, $g);
    }

    return 0;
}

my $pm1 = Math::GMPz::Rmpz_init();
my $nm1 = Math::GMPz::Rmpz_init();

my @results;

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    Math::GMPz::Rmpz_set_str($nm1, $key, 10);
    Math::GMPz::Rmpz_sub_ui($nm1, $nm1, 1);

    if (vecall {

        Math::GMPz::Rmpz_set_str($pm1, $_, 10);
        Math::GMPz::Rmpz_sub_ui($pm1, $pm1, 1);

        is_smooth_over_prod($nm1, $pm1) && is_smooth_over_prod($pm1, $nm1)
    } @factors) {
        say $key;
    }
}

__END__

# Terms > 2^64 (with possible gaps):

73410179782535364796052059
5411695603795048325536175041
95106929041283303531250000001
31197348228454236739150927323898801
10558497564199755330631648092537628169160622081
126217744835361888865876570445244908569293329492211341857910156251
12148637639549114477071860020956143849622919774718138313293457031251
5900324689019449887451851353940562090936525912396137121433584769433600000001
4177392324310826218814556463737392900001943407960199004975124368018024328552246093750000000000000000000000000000000000000000001
879361831036453821125543949192453243128917237544224266734282340295730119548761964672847363652551337171360809414377113469614340239117201810589199173145474561032406759183371360810887592887141239366187714402476721670165867169914359562716332554707359531428023182618702639403640424644576726719757700564249612631862195373427087696051515417662753403815521084610108301719124456314883210969337514431513915452108414913944611394885081652293989903523033434314819867647387511513090358958380855084361115050053209444024748485904601
