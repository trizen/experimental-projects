#!/usr/bin/perl

# Composite numbers n such that phi(n) divides p*(n - 1) for some prime factor p of n-1.
# https://oeis.org/A338998

# Known terms:
#   1729, 12801, 5079361, 34479361, 3069196417

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use Math::Sidef qw(trial_factor);
use List::Util qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

sub my_euler_phi ($factors) {   # assumes n is squarefree
    Math::Prime::Util::GMP::vecprod(map{ ($_ < ~0) ? ($_-1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);
}

my $TRIAL_LIMIT = 1e3;

my $n   = Math::GMPz::Rmpz_init();
my $nm1 = Math::GMPz::Rmpz_init();
my $phi = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %$carmichael) {

    length($key) <= 50 or next;
    #~ Math::Prime::Util::GMP::gcd($key, 3*5*7) > 1 or next;

    my @factors = split(' ', $value);

    $factors[0] < 100 or next;

    Math::GMPz::Rmpz_set_str($phi, my_euler_phi(\@factors), 10);
    Math::GMPz::Rmpz_set_str($n, $key, 10);
    Math::GMPz::Rmpz_sub_ui($nm1, $n, 1);

    my %seen;
    my @trial = trial_factor($nm1, $TRIAL_LIMIT);

    if (vecany { !$seen{$$_}++ && ($$_ < $TRIAL_LIMIT) && ((($nm1 * $$_) % $phi) == 0) } @trial) {
        say $key;
    }
}

__END__

# No terms > 2^64 are known.
