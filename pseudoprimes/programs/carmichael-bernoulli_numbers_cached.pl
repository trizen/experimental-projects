#!/usr/bin/perl

# An interesting subset of Carmichael numbers, defined by Tomasz Ordowski.

#    Let D_k be the denominator of Bernoulli B_k.
#
# For odd n > 1, we have D_{n-1} = Product_{p-1|n-1, p prime} p.
#    Are there odd numbers n > 3 such that n - 1 | D_{n-1} / 2 - 1 ?
#
# If so, then such D_{n-1} / 2 is a Carmichael number (divisible by 3), because lambda(D_{n-1}) = lambda(D_{n-1} / 2) | n - 1.
#
# If not, let's try a weaker condition: lambda(D_{n-1}) | D_{n-1} / 2 - 1 > 2.
#
#    Are there Carmichael numbers of the form D_{2m} / 2 ?

# No such numbers are known...

use 5.020;
use strict;
use warnings;

use Storable;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $carmichael    = retrieve($storable_file);

while (my ($n, $value) = each %$carmichael) {

    my $len = length($n);

    next if $len > 50;

    # Must be divisible by 3
    Math::Prime::Util::GMP::modint($n, 3) == 0 or next;

    my $nm1 = Math::Prime::Util::GMP::subint($n, 1);

    # Product_{p-1|n-1, p prime} p
    my @primes   = grep { is_prime($_) } map { Math::Prime::Util::GMP::addint($_, 1) } Math::Prime::Util::GMP::divisors($nm1);
    my $bern_den = Math::Prime::Util::GMP::vecprod(@primes);

    # lambda(D_{n-1})
    my $lambda_bern_den = Math::Prime::Util::GMP::lcm(map { Math::Prime::Util::GMP::subint($_, 1) } @primes);

    # D_{n-1} / 2 - 1
    $bern_den = Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::divint($bern_den, 2), 1);

    #~ if (Math::Prime::Util::GMP::modint($bern_den, $nm1) eq '0') {
    #~ say $n;
    #~ }

    if ($bern_den > 2 and Math::Prime::Util::GMP::modint($bern_den, $lambda_bern_den) eq '0') {
        say $n;
    }
}

__END__
