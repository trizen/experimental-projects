#!/usr/bin/perl

# An interesting subset of Carmichael numbers, defined by Tomasz Ordowski.

# Problem #1:
#   Let D_k be the denominator of Bernoulli number B_k.
#   Are there numbers n > 3 such that D_{n-1} = 2n ?
#   Equivalently, Product_{p prime, p-1|n-1} p = 2n.
#   If so, it must be a Carmichael number divisible by 3.

# Problem #2:
#   Are there Carmichael numbers n where D_{n-1} = 6n?
#   Two Carmichael numbers found by Amiram Eldar:
#       310049210890163447, 18220439770979212619, ...
#

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

    next if $len > 35;

    my @factors = split(' ', $value);
    @factors == 3 or next;

    # Problem 1 condition
    #~ Math::Prime::Util::GMP::modint($n, 3) == 0 or next;

    my $nm1 = Math::Prime::Util::GMP::subint($n, 1);

    # Product_{p-1|n-1, p prime} p
    my @primes   = grep { is_prime($_) } map { Math::Prime::Util::GMP::addint($_, 1) } Math::Prime::Util::GMP::divisors($nm1);
    my $bern_den = Math::Prime::Util::GMP::vecprod(@primes);

    #~ if ($bern_den eq Math::Prime::Util::GMP::mulint($n, 2)) {   # problem 1
        #~ say $n;
    #~ }

    if ($bern_den eq Math::Prime::Util::GMP::mulint($n, 6)) {   # problem 2
        say $n;
    }
}

__END__

# Some extra terms for problem #2 (not necessarily consecutive)

326454636194318621086787
1789416066515261322576456299
5271222682189523956137705530039
