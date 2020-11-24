#!/usr/bin/perl

# Composite numbers n such that phi(n) divides p*(n - 1) for some prime factor p of n - 1.
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
    Math::GMPz->new(Math::Prime::Util::GMP::vecprod(map{ Math::Prime::Util::GMP::subint($_, 1) } @$factors));
}

my $TRIAL_LIMIT = 1e6;

while (my ($key, $value) = each %$carmichael) {

    Math::Prime::Util::GMP::gcd($key, 3*5*7) > 1 or next;

    my @factors = split(' ', $value);

    my $phi = my_euler_phi(\@factors);
    my $n = Math::GMPz->new($key);
    my $nm1 = $n-1;

    my @trial = trial_factor($nm1, $TRIAL_LIMIT);

    if (vecany { ($$_ < $TRIAL_LIMIT) && ((($nm1 * $$_) % $phi) == 0) } @trial) {
        say $key;
    }
}

__END__

# No terms > 2^64 are known.
