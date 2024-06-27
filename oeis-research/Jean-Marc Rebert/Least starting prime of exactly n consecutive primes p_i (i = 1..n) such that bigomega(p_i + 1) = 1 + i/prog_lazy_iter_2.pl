#!/usr/bin/perl

# Least starting prime of exactly n consecutive primes p_i (i = 1..n) such that bigomega(p_i + 1) = 1 + i.
# https://oeis.org/A369097

# Known terms:
#   3, 5, 541, 997, 328753, 5385217, 1287133, 9483302497, 107887226353

# This version is memory friendly.

# Lower-bounds:
#   a(10) > 13132496513407

use 5.036;
use ntheory     qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);

my $n = 10;

my $multiplier = 1.1;
my $from       = 13132496513407;
my $upto       = int($multiplier * $from);

#~ my $multiplier = 2;
#~ my $from       = 2;
#~ my $upto       = int($multiplier * $from);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(2, $k));

    sub ($m, $p, $k) {

        if ($k == 1) {

            forprimes {
                $callback->($m * $_);
            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(2, 2, $k-1);
}

while (1) {

    my $t0 = [gettimeofday];
    say "Sieving range: ($from, $upto)";

    my $found = 0;
    my $min   = 'inf';

    almost_prime_numbers(
        $from, $upto,
        $n + 1,
        sub ($k) {

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

                    if ($ok) {
                        if (is_almost_prime($n + 2, next_prime($k) + 1)) {
                            say "a(", $n+1, ") <= $q";
                        }
                        elsif ($q < $min) {
                            say "a($n) <= $q";
                            $found = 1;
                            $min   = $q;
                        }
                    }
                }
            }
        }
    );

    say "Sieving took: ", tv_interval($t0), " seconds\n";

    last if $found;

    $from = $upto;
    $upto = int($multiplier * $from);
}

__END__
Sieving range: (5750467850, 7475608205)
Sieving took: 21.310572 seconds

Sieving range: (7475608205, 9718290666)
a(8) <= 9483302497
Sieving took: 27.49441 seconds

perl prog_lazy_iter_2.pl  103.30s user 0.08s system 95% cpu 1:48.04 total

Sieving range: (9119789245422, 10943747094506)
Sieving took: 7250.08632 seconds

Sieving range: (10943747094506, 13132496513407)
Sieving took: 8525.661926 seconds

Sieving range: (13132496513407, 15758995816088)
^C
perl prog_lazy_iter_2.pl  43269.00s user 48.38s system 96% cpu 12:25:40.15 total
