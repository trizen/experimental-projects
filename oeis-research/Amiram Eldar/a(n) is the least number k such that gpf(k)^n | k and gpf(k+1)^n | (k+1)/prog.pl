#!/usr/bin/perl

# a(n) is the least number k such that P(k)^n | k and P(k+1)^n | (k+1), where P(k) = A006530(k) is the largest prime dividing k, or -1 if no such k exists.
# https://oeis.org/A354567

# Known terms:
#   1, 8, 6859, 11859210

# Known upper-bounds:
#   a(5) <= 437489361912143559513287483711091603378 (De Koninck, 2009).

# Lower-bounds:
#  a(5) > 10^18
#  a(6) > 10^19

# Beside 11859210, no other term k exists < 10^18 that satisfy:
#   gpf(k)^4 | k and gpf(k+1) | (k+1)

use 5.020;
use strict;
use warnings;

use ntheory qw(primes is_smooth);
use Math::Prime::Util::GMP qw(chinese powint mulint addint);

my $n = 5;

#my $plimit = 20000;
#my $klimit = 20;

my $plimit = 60000;
my $klimit = 20;

#my @primes = @{primes(11, $plimit)};
my @primes = @{primes(1000, $plimit)};

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

        next if ($p <= 5e4 and $q <= 5e4);      # already checked with klimit=20
        #next if ($p > 4957 and $q > 6619);      # already checked with klimit=20

        my $qn = powint($q, $n);
        my $c  = chinese([0, $pn], [-1, $qn]);
        my $m  = mulint($pn, $qn);

        foreach my $k (0 .. $klimit) {
            my $t = addint(mulint($m, $k), $c);

            if ($n == 5) {
                $t > 1e18 or next;
            }
            elsif ($n == 6) {
                $t > 1e19 or next;
            }

            #is_smooth(mulint($t, addint($t, 1)), (($p > $q) ? $p : $q)) || next;

            if (
                ($p < $q)
                ? (is_smooth($t, $p) and is_smooth(addint($t, 1), $q))
                : (is_smooth(addint($t, 1), $q) and is_smooth($t, $p))
            ) {
                say "[$k] Found: a($n) <= $t";
            }
        }
    }
}

__END__
[11]  Found: a(5) <= 437489361912143559513287483711091603378
[142] Found: a(5) <= 5391726395735343473481567991870320051979
[12]  Found: a(5) <= 22748992615102631934745928628382078239867
[11]  Found: a(5) <= 8250351204235843413274102593592289950249874
