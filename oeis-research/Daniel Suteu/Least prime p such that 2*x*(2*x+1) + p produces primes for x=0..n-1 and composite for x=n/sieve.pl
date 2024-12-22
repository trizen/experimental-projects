#!/usr/bin/perl

# Least prime p such that 2*x*(2*x+1) + p produces primes for x=0..n-1 and composite for x=n.
# https://oeis.org/A?????

# Known terms:
#   2, 5, 23, 47, 11, 977, 6317, 17, 347, 10457, 2267, 1217, 36387086621, 2468556939281, 8018748579971

# Cf. A164926

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + 2*$n*(2*$n+1)) } sieve_prime_cluster($lo, $hi, map { 2*$_*(2*$_+1) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " } # ~~~~

=cut

# Other terms:
#   a(20) = 41

# Lower-bounds:
#

use 5.036;
use ntheory qw(:all);
use Math::Sidef qw(polygonal);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving for a($n): [$lo, $hi]";
        my @terms = grep { !is_prime($_ + 2*$n*(2*$n+1)) } sieve_prime_cluster($lo, $hi, map { 2*$_*(2*$_+1) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.5 * $lo);
    }
}

my $n  = 15;
my $lo = 1;
my $hi = int(1.5 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__

isok(p, n) = for (k=0, n-1, if(!isprime(p + 2*k*(2*k+1)), return(0))); return(!isprime(p + 2*n*(2*n+1)));
a(n) = forprime(p=2, oo, if(isok(p, n), return(p))); \\ ~~~~
