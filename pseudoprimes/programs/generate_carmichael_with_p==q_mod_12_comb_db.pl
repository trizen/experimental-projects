#!/usr/bin/perl

# Generate Carmichael that have all prime factors p congruent to a constant k modulo 12.
# (takes around 27 minutes to complete)

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util   qw(uniq);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my %table;

use IO::Handle;
open my $fh, '>>', 'special_carmichael_comb.txt';
$fh->autoflush(1);

say ":: Generating... Please wait...";

my %seen_p;

{
    my $nm1 = Math::GMPz::Rmpz_init();
    my $pm1 = Math::GMPz::Rmpz_init();

    sub my_is_carmichael_faster ($n, $factors) {
        Math::GMPz::Rmpz_set_str($nm1, $n, 10);
        Math::GMPz::Rmpz_sub_ui($nm1, $nm1, 1);
        return if not vecall {
            ($_ < ~0) ? Math::GMPz::Rmpz_divisible_ui_p($nm1, $_ - 1) : do {
                Math::GMPz::Rmpz_set_str($pm1, $_, 10);
                Math::GMPz::Rmpz_sub_ui($pm1, $pm1, 1);
                Math::GMPz::Rmpz_divisible_p($nm1, $pm1);
            }
        }
        @$factors;
        return 1;
    }
}

my %seen;

while (my ($n, $value) = each %db) {

    my @factors = uniq(split(' ', $value));

    scalar(@factors) >= 5 or next;

    my %table;

    foreach my $p (@factors) {
        if (modint(divint(subint(mulint($p, $p), 1), 2), 12) == 0) {
            push @{$table{modint($p, 12)}}, $p;
        }
    }

    foreach my $group (values %table) {

        scalar(@$group) >= 4                          or next;
        Math::Prime::Util::GMP::vecprod(@$group) > ~0 or next;

        my $size = scalar(@$group);

        foreach my $k (4 .. $size) {

            binomial($size, $k) <= 1e2 or next;

            forcomb {
                my @f = @{$group}[@_];
                my $t = Math::Prime::Util::GMP::vecprod(@f);
                if ($t > ~0 and my_is_carmichael_faster($t, \@f)) {

                    #say $t;
                    say $fh $t;
                }
            }
            $size, $k;
        }
    }
}

say ":: Done...";

close $fh;
dbmclose(%db);
