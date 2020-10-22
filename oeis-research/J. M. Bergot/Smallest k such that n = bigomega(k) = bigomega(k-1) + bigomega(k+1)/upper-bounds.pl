#!/usr/bin/perl

# a(n) is the first k such that n = Omega(k) = Omega(k-1) + Omega(k+1), or 0 if there is no such k, where Omega is A001222.
# https://oeis.org/A338302

use 5.014;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);

# a(20) <= 816982654976
# a(21) <= 2558408523776
# a(22) <= 5707559600128
# a(23) <= 24607835029504

my @arr = (2) x 19;
my $v = vecprod(@arr);

my $r = scalar(@arr);
my $n = 24;

foralmostprimes {
    my $k = $v * $_;
    if (prime_bigomega($k-1) + prime_bigomega($k+1) == $n) {
        say $k;
        lastfor;
    }
} ($n - $r), 1, 1e11;
