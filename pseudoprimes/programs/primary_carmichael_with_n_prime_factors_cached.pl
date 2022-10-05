#!/usr/bin/perl

# Least primary Carmichael number (A324316) with n prime factors.
# https://oeis.org/A306657

# Known terms:
#   1729, 10606681, 4872420815346001

# Primary Carmichael numbers.
# https://oeis.org/A324316

# Squarefree integers m > 1 such that if prime p divides m, then the sum of the base-p digits of m equals p. It follows that m is then a Carmichael number (A002997).

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";

my $carmichael = retrieve($carmichael_file);

my %table;

while (my($key, $value) = each %$carmichael) {

    my @factors = split(' ', $value);
    my $count   = scalar(@factors);

    next if ($count <= 5);

    (vecall { $_ eq vecsum(Math::Prime::Util::GMP::todigits($key, $_)) } @factors) || next;

    my $z = Math::GMPz::Rmpz_init_set_str($key, 10);

    if (exists $table{$count}) {
        next if ($table{$count} < $z);
    }

    say "a($count) <= $key";
    $table{$count} = $z;
}

say "\nFinal results:\n";

foreach my $count (sort { $a <=> $b } keys %table) {
    say "a($count) <= $table{$count}";
}

__END__

# No upper-bound for a(6) is known.
