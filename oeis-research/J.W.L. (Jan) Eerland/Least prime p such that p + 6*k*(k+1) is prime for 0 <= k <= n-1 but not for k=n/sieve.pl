#!/usr/bin/perl

# a(n) is the least prime p such that p + 6*k*(k+1) is prime for 0 <= k <= n-1 but not for k=n.
# https://oeis.org/A370387

# Known terms:
#   2, 19, 5, 67, 7, 281, 1051, 6791, 11, 115599457, 365705201, 79352440891, 286351937491, 5810592517241, 17

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + 6*$n*($n+1)) } sieve_prime_cluster($lo, $hi, map { 6*$_*($_+1) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " } # ~~~~

=cut

# Lower-bounds:
#   a(16) > 41943044194303
#   a(16) > 83886088388607   (17 December 2024)
#   a(16) > 167772176777215  (18 December 2024)
#   a(16) > 335544353554431  (18 December 2024)
#   a(16) > 660090302112534  (20 December 2024)
#   a(16) > 666691205133660  (22 December 2024)
#   a(16) > 774007791978400  (22 December 2024)
#   a(16) > 936549428293866  (24 December 2024)
#   a(16) > 1508322219761559 (29 December 2024)
#   a(16) > 1825069885911488 (29 December 2024)

# New term found:
#   a(16) = 1942721697854617

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving for a($n): [$lo, $hi]";
        my @terms = grep { !is_prime($_ + 6 * $n * ($n + 1)) } sieve_prime_cluster($lo, $hi, map { 6 * $_ * ($_ + 1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.1 * $lo);
    }
}

my $n  = 16;
my $lo = 1825069885911488;
my $hi = int(1.1 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__
a(1) = 2
a(2) = 19
a(3) = 5
a(4) = 67
a(5) = 7
a(6) = 281
a(7) = 1051
a(8) = 6791
a(9) = 11
a(10) = 115599457
a(11) = 365705201
a(12) = 79352440891
a(13) = 286351937491
a(14) = 5810592517241
a(15) = 17
a(16) = 1942721697854617

__END__
:: Sieving for a(16): [1825069885911488, 2007576874502637]
a(16) = 1942721697854617
perl sieve.pl  3193.15s user 0.92s system 98% cpu 53:52.21 total
