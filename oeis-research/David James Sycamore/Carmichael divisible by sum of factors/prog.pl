#!/usr/bin/perl

# Carmichael numbers divisible by the sum of their prime factors, sopfr (A001414).
# https://oeis.org/A309003

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::AnyNum qw(is_smooth);

sub odd_part ($n) {
    $n >> valuation($n, 2);
}

my %seen;
my @nums;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    length($n) > 15 and next;

    if ($n < 3240392401) {
        next;
    }

    next if $seen{$n}++;

   # is_smooth($n, 1e7) || next;
    is_carmichael($n) || next;

    say "Candidate: $n";

    if ($n > ~0) {
        $n = Math::GMPz->new("$n");
    }

    push @nums, $n;
}

@nums = sort { $a <=> $b } @nums;

say "There are ", scalar(@nums), " total numbers";

foreach my $n (@nums) {
    #say "Testing: $n";
    #if (odd_part($n - 1) == odd_part(euler_phi($n))) {
    #    die "Found counter-example: $n";
    #}

    if ($n % vecsum(factor($n))  == 0) {
        print $n, ", ";
    }
}

__END__
3240392401, 13577445505, 14446721521, 84127131361, 203340265921, 241420757761, 334797586201, 381334973041, 461912170321, 1838314142785, 3636869821201, 10285271821441, 17624045440981, 18773053896961, 20137015596061, 24811804945201, 26863480687681, 35598629998801
