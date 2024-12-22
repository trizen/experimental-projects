#!/usr/bin/perl

# Least prime p such that x*(x+1)*(x+2) + p produces primes for x=0..n-1 and composite for x=n.
# https://oeis.org/A?????

# Known terms:
#   2, 11, 5, 13, 7, 443, 47, 173, 189523, 14298023, 103, 5208145367, 1636561295087, 11301892683727, 59063566700087

# Cf. A164926

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + $n*($n+1)*($n+2)) } sieve_prime_cluster($lo, $hi, map { $_*($_+1)*($_+2) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " } # ~~~~

=cut

# Lower-bounds:
#   a(16) > 297519376459246

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving for a($n): [$lo, $hi]";
        my @terms = grep { !is_prime($_ + $n * ($n+1) * ($n+2)) } sieve_prime_cluster($lo, $hi, map { $_ * ($_+1) * ($_+2) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.5 * $lo);
    }
}

my $n  = 16;
my $lo = 1;
my $hi = int(1.5 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__

isok(p, n) = for (k=0, n-1, if(!isprime(p + k*(k+1)*(k+2)), return(0))); return(!isprime(p + n*(n+1)*(n+2)));
a(n) = forprime(p=2, oo, if(isok(p, n), return(p))); \\ ~~~~
