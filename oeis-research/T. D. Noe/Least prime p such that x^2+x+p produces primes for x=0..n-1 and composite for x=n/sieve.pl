#!/usr/bin/perl

# Least prime p such that x^2+x+p produces primes for x=0..n-1 and composite for x=n.
# https://oeis.org/A164926

# Known terms:
#   2, 3, 107, 5, 347, 1607, 1277, 21557, 51867197, 11, 180078317, 1761702947, 8776320587, 27649987598537, 291598227841757, 17

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + $n*($n+1)) } sieve_prime_cluster($lo, $hi, map { $_*($_+1) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " } # ~~~~

=cut

# Lower-bounds:
#   a(17) > 291598227841757
#   a(17) > 1783388239117169

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving for a($n): [$lo, $hi]";
        my @terms = grep { !is_prime($_ + $n * ($n+1)) } sieve_prime_cluster($lo, $hi, map { $_ * ($_+1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.1 * $lo);
    }
}

my $n  = 17;
my $lo = 1783388239117169;
my $hi = int(1.1 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__

isok(p, n) = for (k=0, n-1, if(!isprime(p + k*(k+1)), return(0))); return(!isprime(p + n*(n+1)));
a(n) = forprime(p=2, oo, if(isok(p, n), return(p))); \\ ~~~~
