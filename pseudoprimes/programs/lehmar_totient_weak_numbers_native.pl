#!/usr/bin/perl

# Composite numbers n such that phi(n) divides p*(n - 1) for some prime factor p of n-1.
# https://oeis.org/A338998

# Known terms:
#   1729, 12801, 5079361, 34479361, 3069196417

use 5.020;
use strict;
use warnings;

#use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
#use Math::Sidef qw(trial_factor);
#use List::Util qw(uniq);

my @terms;
my %seen;

while (<>) {

    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n > ~0;

    #~ next if $n < ~0;
    #~ next if length($n) > 25;

    my $phi = euler_phi($n);
    my $nm1 = subint($n,1);

    if (vecany { Math::Prime::Util::GMP::modint(Math::Prime::Util::GMP::mulint($nm1, $_), $phi) == 0 } factor($nm1)) {
        if (!$seen{$n}++) {
            say $n;
            push @terms, $n;
        }
    }
}

say "\n=> Final results:\n";

@terms = sort {$a <=> $b} @terms;
say for @terms;

__END__

# The sequence also includes:

1729
12801
5079361
34479361
3069196417
23915494401
1334063001601
6767608320001
33812972024833
380655711289345
1584348087168001
1602991137369601
6166793784729601
1531757211193440001
