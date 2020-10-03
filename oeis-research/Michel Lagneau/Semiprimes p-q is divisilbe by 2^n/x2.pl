#!/usr/bin/perl

# a(n) is the least k such that k^2 + 1 is a semiprime p*q, p < q, and (q - p)/2^n is prime.
# https://oeis.org/A258780

# New terms found:
#   a(20) = 126072244
#   a(21) = 9586736
#   a(22) = 4156840
#   a(23) = 542759984           # to be added
#   a(24) = 1017981724          # to be added
#   a(25) = 2744780140          # to be added
#   a(26) = 405793096           # to be added
#   a(27) = 148647496           # to be added
#   a(28) = 1671024916          # to be added
#   ....
#   a(30) = 1515257276          # to be added

# Another example for a(27) is 2808502256.

# It seems that all terms are multiples of 4.

use 5.014;
use ntheory qw(:all);

sub f {

    my %seen;

    foreach my $n (1 .. 1e9) {

        my $k = $n << 1;                # all terms are even
        my $t = $k * $k + 1;

        if (is_semiprime($t)) {

            my ($p, $q) = factor($t);
            my $v = valuation($q - $p, 2);

            #$v > 22 or next;

            if (not exists $seen{$v - 1} and ((1<<$v) == $q - $p)) {
                $seen{$v - 1} = 1;
                say $v-1, " => $k,";
            }
            elsif (not exists $seen{$v} and is_prime(($q - $p) >> $v)) {
                $seen{$v} = 1;
                say "$v => $k,";
            }
        }
    }
}

f();

__END__
2 => 8,
3 => 12,
5 => 64,
4 => 140,
7 => 196,
8 => 1300,
9 => 1600,
6 => 2236,
11 => 5084,
10 => 6256,
15 => 36680,
19 => 104120,
13 => 246196,
12 => 248756,
14 => 484400,
17 => 821836,
16 => 887884,
18 => 1559116,
22 => 4156840,
21 => 9586736,
20 => 126072244,
27 => 148647496,
26 => 405793096,
23 => 542759984,
24 => 1017981724,
30 => 1515257276,
28 => 1671024916,
25 => 2744780140,
