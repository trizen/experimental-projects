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

sub dynamicPreimage ($N, $L) {

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            foreach my $d (divisors(divint($N, $x))) {
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            }
        }
        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    sort { $a <=> $b } @{$r{$N}};
}

sub cook_sigma ($N, $k) {
    my %L;

    foreach my $d (divisors($N)) {

        next if ($d == 1);

        foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

            my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
            my $t = valuation($q, $p);

            next if ($t <= $k or ($t % $k) or $q != powint($p, $t));

            push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
        }
    }

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    ($N == 1) ? (1) : dynamicPreimage($N, cook_sigma($N, $k));
}

# 2301403000, 2320213000, 2410132000, 3201112210, 4000014202,

#say for inverse_sigma(40320);

# 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600, 6227020800, 87178291200
# 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600

my @values;

foreach my $t (1..13) {

    say "Processing: $t";
    my $n = factorial($t);

    #say "Processing: $n";
    #(my @inv = inverse_sigma($n)) || next;

    foreach my $k (inverse_sigma($n)) {

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

Terems for sum of digits = 1..12:
    1, 20132, 2005210, 2007010, 2030212, 2203102, 22121210, 33200201, 220000026, 230110302


Terms for sum of digits = 13:
    2301403000, 2320213000, 2410132000, 3201112210, 4000014202


Terms for sum of digits = 15:
    400230021120, 414102021000, 430011013020, 532010011110


Terms for sum of digits = 16:
    10001300332030, 10010123111032, 10030302411010, 10060311020110, 10120001550010, 20002100200081, 20105032001011


(Note: there are no terms for sum of digits = 14)
