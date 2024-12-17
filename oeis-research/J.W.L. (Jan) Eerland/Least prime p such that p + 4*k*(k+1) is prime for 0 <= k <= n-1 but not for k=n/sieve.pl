#!/usr/bin/perl

# a(n) is the least prime p such that p + 4*k*(k+1) is prime for 0 <= k <= n-1 but not for k=n.
# https://oeis.org/A371024

# Known terms:
#   2, 3, 29, 5, 23, 269, 272879, 149, 61463, 929, 7426253, 2609, 233, 59

# New term:
#   a(15) = 78977932125503

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + 4*$n*($n+1)) } sieve_prime_cluster($lo, $hi, map { 4*$_*($_+1) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " }

=cut

# Lower-bounds:
#   a(15) > 2.3*10^13 if it exists. - David A. Corneth, Apr 12 2024
#   a(15) > 60000000000003

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving: [$lo, $hi]";
        my @terms = grep { !is_prime($_ + 4 * $n * ($n + 1)) } sieve_prime_cluster($lo, $hi, map { 4 * $_ * ($_ + 1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = 2 * $lo;
    }
}

my $n  = 15;
my $lo = 60000000000003;
my $hi = int(1.5 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__
a(1) = 2
a(2) = 3
a(3) = 29
a(4) = 5
a(5) = 23
a(6) = 269
a(7) = 272879
a(8) = 149
a(9) = 61463
a(10) = 929
a(11) = 7426253
a(12) = 2609
a(13) = 233
a(14) = 59
