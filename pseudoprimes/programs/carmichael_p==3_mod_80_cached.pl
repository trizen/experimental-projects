#!/usr/bin/perl

# Let p_1..p_k be distinct prime numbers and let n = p_1 * ... p_k.

# If the following conditions hold:
#   a) k == 1 (mod 4) or k == 3 (mod 4)
#   b) p_i == 3 (mod 80) for every i in {1..k}.
#   c) (p_i-1) | (n-1) for every i in {1..k}.
#   d) (p_i+1) | (n+1) for every i in {1..k}.

# Then n is a counter-example to Agrawal's conjecture.

# The only Carmichael number below 2^64 with all prime factors p == 3 (mod 80):
#   330468624532072027

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($storable_file);

my @results;

while (my($key, $value) = each %$carmichael) {

    my $rem = Math::Prime::Util::GMP::modint($key, 80);

    ($rem == 27) || ($rem == 3) || next;

    my @factors = split(' ', $value);

    if (scalar(@factors) % 2 and vecall { Math::Prime::Util::GMP::modint($_, 80) == 3 } @factors) {
        push @results, Math::GMPz->new($key);
    }
}

@results = sort {$a <=> $b} @results;

foreach my $n (@results) {
    say $n;
}

__END__

# Terms > 2^64:

1358406397003392026912594827
194462892367341977828363075381947
