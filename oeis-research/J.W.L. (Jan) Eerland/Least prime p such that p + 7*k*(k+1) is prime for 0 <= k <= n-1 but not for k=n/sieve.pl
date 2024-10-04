#!/usr/bin/perl

# a(n) is the least prime p such that p + 7*k*(k+1) is prime for 0 <= k <= n-1 but not for k=n.
# https://oeis.org/A376675

# New terms:
#   a(16) = 17

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + 7*$n*($n+1)) } sieve_prime_cluster($lo, $hi, map { 7*$_*($_+1) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " }

=cut

use 5.036;
use ntheory qw(:all);

sub a {
    my $n = shift;

    my $lo = 2;
    my $hi = 2 * $lo;

    while (1) {
        my @terms = grep { !is_prime($_ + 7 * $n * ($n + 1)) } sieve_prime_cluster($lo, $hi, map { 7 * $_ * ($_ + 1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = 2 * $lo;
    }
}

foreach my $n (1 .. 100) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 2
a(2) = 3
a(3) = 59
a(4) = 5
a(5) = 89
a(6) = 599
a(7) = 3329
a(8) = 617
a(9) = 269
a(10) = 21107
a(11) = 9833477
a(12) = 19497833669
a(13) = 215830859597
a(14) = 111338387
