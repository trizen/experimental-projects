#!/usr/bin/perl

# Numbers k such that sigma(k) = (sum of digits of k)!.
# https://oeis.org/A324061 (recycled)

# Known terms:
#   1, 20132, 2005210, 2007010, 2030212, 2203102, 22121210, 33200201, 220000026, 230110302, 2301403000, 2320213000, 2410132000, 3201112210, 4000014202, 400230021120, 414102021000, 430011013020, 532010011110, 10001300332030, 10010123111032, 10030302411010, 10060311020110, 10120001550010, 20002100200081, 20105032001011

use utf8;
use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

use Math::GMPz;

##use Math::AnyNum qw();
##use Math::GMP qw(:constant);

#<<<
#~ $| = 1;
#~ foreach my $k (23014030000 - 100 .. 1e11) {

    #~ if (exists($factorial{vecsum(split(//, $k))})) {
        #~ if (divisor_sum($k) == $factorial{vecsum(split(//, $k))}) {
            #~ print($k, ", ");
        #~ }
    #~ }
#~ }
#>>>

#~ __END__

#use Memoize qw(memoize);
#memoize('inverse_sigma');

my %lookup_mpz;

sub mpz_object ($n) {
    $lookup_mpz{$n} //= Math::GMPz::Rmpz_init_set_str("$n", 10);
}

my %seen;

sub inverse_sigma ($n, $m = 3) {

    return [1] if ($n == 1);

    if (exists $seen{"$n $m"}) {
        return $seen{"$n $m"};
    }

    my @R;
    foreach my $d (map { mpz_object($_) } grep { $_ >= $m } divisors($n)) {
        foreach my $p (map { $_->[0] } factor_exp($d - 1)) {
            my $P = $d * ($p - 1) + 1;
            my $k = valuation($P, $p) - 1;
            next if (($k < 1) || ($P != $p**($k + 1)));
            my $z = $p**$k;
            foreach my $v (@{inverse_sigma($n / $d, $d)}) {
                if ($v % $p != 0) {
                    push @R, $v * $z;
                }
            }
        }
    }

    #@R = uniq(@R);
    $seen{"$n $m"} = \@R;
}

# 2301403000, 2320213000, 2410132000, 3201112210, 4000014202,

#say for inverse_sigma(40320);

# 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600, 6227020800, 87178291200
# 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600

my @values;

foreach my $t (1..12) {

    say "Processing: $t";
    my $n = factorial($t);

    #say "Processing: $n";
    #(my @inv = inverse_sigma($n)) || next;

    foreach my $k (@{inverse_sigma($n)}) {

        #say "Testing: $k";
        if (vecsum(split(//, $k)) == $t) {
            push @values, $k;
        }
    }

    #push @values, @inv;
}

local $| = 1;

foreach my $value (sort { $a <=> $b } @values) {
    print($value, ", ");
}

say '';

__END__

Terems for sum of digits = 1..12 (took ~3 seconds):
    1, 20132, 2005210, 2007010, 2030212, 2203102, 22121210, 33200201, 220000026, 230110302


Terms for sum of digits = 13 (took ~12 seconds):
    2301403000, 2320213000, 2410132000, 3201112210, 4000014202


Terms for sum of digits = 15 (took ~2 minutes):
    400230021120, 414102021000, 430011013020, 532010011110


Terms for sum of digits = 16 (took ~4.5 minutes):
    10001300332030, 10010123111032, 10030302411010, 10060311020110, 10120001550010, 20002100200081, 20105032001011


(Note: there are no terms for sum of digits = 14)
