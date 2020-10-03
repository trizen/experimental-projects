#!/usr/bin/perl

# Smallest m such that each digit (0-9) appears exactly n times in the concatenation of m and pi(m).
# https://oeis.org/A323604

#   102756, 10013236879, 1000112354597667

use 5.014;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

# 100000000000000000000
# 100001112222333344445

my $from = Math::GMPz->new(10)**20;
my $count = Math::GMPz->new("2220819602560918840");

for (;;) {

    say "Testing $from";

    my %hash;
    $hash{$_}++ for split(//, "$from$count");

    if (vecall {$_ == 2} values %hash) {
        die "\nFound term: $from (primepi = $count)\n";
    }

    $from = next_prime($from);
    Math::GMPz::Rmpz_add_ui($count, $count, 1);
}

__END__
PRIME PI < 10^n

0 0
1 4
2 25
3 168
4 1229
5 9592
6 78498
7 664579
8 5761455
9 50847534
10 455052511
11 4118054813
12 37607912018
13 346065536839
14 3204941750802
15 29844570422669
16 279238341033925
17 2623557157654233
18 24739954287740860
19 234057667276344607
20 2220819602560918840
21 21127269486018731928
22 201467286689315906290
23 1925320391606803968923
24 18435599767349200867866
25 176846309399143769411680
26 1699246750872437141327603
27 16352460426841680446427399
