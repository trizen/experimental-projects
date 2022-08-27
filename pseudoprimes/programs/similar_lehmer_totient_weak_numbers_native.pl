#!/usr/bin/perl

# Carmichael numbers n such that (n-1)/gcd(n-1, phi(n)) is a prime that divides phi(n).
# https://oeis.org/A???

# Terms < 10^18:
#   6601, 2704801, 6840001, 172290241, 2597928961, 6310724545, 23330449801, 24899816449, 32239998001, 304989068161, 340218584641, 498210476401, 3139170212101, 80605134955801, 1126827419481793, 1234652134464001, 3139042491456769, 7328369849463469, 9437569245498241, 11985924995083901, 13148988547437601, 16187797671051601, 171189355538562901, 221446773258202801, 343157330424887749, 631203816383712001, 863221147528126465

# Sequence inspired by:
#   https://oeis.org/A338998

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
    is_carmichael($n) || next;

    #~ next if $n < ~0;
    #~ next if length($n) > 30;

    my $phi = euler_phi($n);
    my $nm1 = subint($n, 1);

    my $p = divint($nm1, gcd($phi, $nm1));

    if (modint($phi, $p) == 0 and is_prime($p)) {
        if (!$seen{$n}++) {
            if ($p == 1) {
                die "Found a Lehmer number: $n";
            }
            say $n;
            push @terms, $n;
        }
    }
}

say "\n=> Final results:\n";

@terms = sort { $a <=> $b } @terms;
say for @terms;

__END__

# All terms < 2^64:

6601
2704801
6840001
172290241
2597928961
6310724545
23330449801
24899816449
32239998001
304989068161
340218584641
498210476401
3139170212101
80605134955801
1126827419481793
1234652134464001
3139042491456769
7328369849463469
9437569245498241
11985924995083901
13148988547437601
16187797671051601
171189355538562901
221446773258202801
343157330424887749
631203816383712001
863221147528126465
1774634562916749601
11357082006980542561
