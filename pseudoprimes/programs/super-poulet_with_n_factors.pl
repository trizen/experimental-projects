#!/usr/bin/perl

# Least super-Poulet number (A050217) with n distinct prime factors.
# https://oeis.org/A328665

# Known terms:
#   341, 294409, 9972894583, 1264022137981459, 14054662152215842621

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

# a(7)  <= 1842158622953082708177091
# a(8)  <= 192463418472849397730107809253922101
# a(9)  <= 1347320741392600160214289343906212762456021
# a(10) <= 70865138168006643427403953978871929070133095474701
# a(11) <= 3363391752747838578311772729701478698952546288306688208857
# a(12) <= 132153369641266990823936945628293401491197666138621036175881960329
# a(13) <= 9105096650335639994239038954861714246150666715328403635257215036295306537

sub is_super_poulet ($n, @factors) {
    Math::Prime::Util::GMP::powmod(2, Math::Prime::Util::GMP::gcd(map { $_ - 1 } @factors), $n) eq '1';
}

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;
    next if length($n) >= 35;

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    $n = Math::GMPz::Rmpz_init_set_str($n, 10);

    #is_smooth($n, 16681005) || next;
    is_smooth($n, 68897953) || next;

    #say "Testing: $n";

    my @factors = Math::Prime::Util::GMP::factor($n);
    my $count   = scalar(@factors);

    next if ($count < 7);

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    if (is_super_poulet($n, @factors)) {
        $table{$count} = $n;
        printf("a(%2d) <= %s\n", $count, $n);
    }
}
