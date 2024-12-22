#!/usr/bin/perl

# Primes p such that the polynomial x^2 + x + p generates only primes for x=1..13.
# https://oeis.org/A253605

# Known terms:
#   17, 41, 27649987598537, 30431463129071

# New terms:
#   58326356511581
#   161966446726157
#   291598227841757

=for comment

# One-line program:

use ntheory qw(:all); local $| = 1; my $lo = 2; my $hi = 2*$lo; while (1) { print "$_, " for sieve_prime_cluster($lo, $hi, map { $_*($_+1) } 1..13); $lo = $hi+1; $hi = 2*$lo } # ~~~~

=cut

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving: [$lo, $hi]";
        my @terms = sieve_prime_cluster($lo, $hi, map { $_ * ($_ + 1) } 1 .. $n);
        say for @terms;
        $lo = $hi + 1;
        $hi = int(1.5 * $lo);
    }
}

my $n  = 13;
my $lo = 297519376459246;
my $hi = int(1.5 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__
