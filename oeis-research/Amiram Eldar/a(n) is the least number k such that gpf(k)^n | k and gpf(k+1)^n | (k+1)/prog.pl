#!/usr/bin/perl

# a(n) is the least number k such that P(k)^n | k and P(k+1)^n | (k+1), where P(k) = A006530(k) is the largest prime dividing k, or -1 if no such k exists.
# https://oeis.org/A354567

# Known terms:
#   1, 8, 6859, 11859210

# Known upper-bounds:
#   a(5) <= 437489361912143559513287483711091603378 (De Koninck, 2009).

use 5.020;
use strict;
use warnings;

use ntheory qw(primes);
use Math::Prime::Util::GMP qw(chinese is_smooth powint mulint addint);

my $n = 6;

my $plimit = 20000;
my $klimit = 20;

my @primes = @{primes(11, $plimit)};

#my @primes = (4957, 6619);

#~ $plimit *= 4;
#~ my @primes = @{primes($plimit>>1, $plimit)};

#~ $klimit = 0;
#~ $plimit = 1e5;
#~ @primes = @{primes(1e4,$plimit)};

say ":: Searching for a($n) with max(p) = $plimit";
printf(":: Cost: ~10^%.3f\n", log(scalar(@primes)**2 * ($klimit + 1)) / log(10));

foreach my $p (@primes) {
    my $pn = powint($p, $n);
    foreach my $q (@primes) {

        next if ($p == $q);

        my $qn = powint($q, $n);
        my $c  = chinese([0, $pn], [-1, $qn]);
        my $m  = mulint($pn, $qn);

        foreach my $k (0 .. $klimit) {
            my $t = addint(mulint($m, $k), $c);

            if (is_smooth($t, $p) and is_smooth(addint($t, 1), $q)) {
                say "[$k] Found: a($n) <= $t";
            }
        }
    }
}
