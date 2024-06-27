#!/usr/bin/perl

# Least starting prime of exactly n consecutive primes p_i (i = 1..n) such that bigomega(p_i + 1) = 1 + i.
# https://oeis.org/A369097

# Known terms:
#   3, 5, 541, 997, 328753, 5385217, 1287133, 9483302497, 107887226353

# This version is memory friendly.

# Lower-bounds:
#   a(10) > 4398046511104

use 5.036;
use ntheory     qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);

my $n = 6;

my $from = 2;
my $upto = 2 * $from;

while (1) {

    my $t0 = [gettimeofday];
    say "Sieving range: ($from, $upto)";

    foralmostprimes {

        my $k = $_;

        if (is_prime($k - 1)) {

            my $q = prev_prime($k - 1);

            if (is_almost_prime($n, $q + 1)) {
                my $ok = 1;
                foreach my $j (3 .. $n) {
                    $q = prev_prime($q);
                    if (is_almost_prime($n - $j + 2, $q + 1)) {
                        ## ok
                    }
                    else {
                        $ok = 0;
                        last;
                    }
                }

                if ($ok and !is_almost_prime($n + 2, next_prime($k) + 1)) {
                    say "a($n) = $q";
                    exit;
                }
            }
        }
    }
    $n + 1, $from, $upto;

    say "Sieving took: ", tv_interval($t0), " seconds\n";

    $from = $upto;
    $upto = int(2 * $from);
}

__END__
Sieving range: (4294967296, 8589934592)
Sieving range: (8589934592, 17179869184)
a(8) = 9483302497
perl prog_lazy_iter.pl  98.52s user 0.76s system 99% cpu 1:40.14 total

Sieving range: (34359738368, 68719476736)
Sieving range: (68719476736, 137438953472)
a(9) = 107887226353
perl prog_lazy_iter.pl  730.65s user 1.83s system 94% cpu 12:52.16 total

# Searching for a(10):
Sieving took: 3552.052777 seconds
Sieving range: (1099511627776, 2199023255552)
Sieving took: 7240.632626 seconds
Sieving range: (2199023255552, 4398046511104)
Sieving took: 18261.820512 seconds
Sieving range: (4398046511104, 8796093022208)
^C
perl prog_lazy_iter.pl  55130.48s user 109.24s system 92% cpu 16:37:08.08 total
