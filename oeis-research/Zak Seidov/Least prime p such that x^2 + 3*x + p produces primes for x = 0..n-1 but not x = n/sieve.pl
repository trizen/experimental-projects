#!/usr/bin/perl

# Least prime p such that x^2 + 3*x + p produces primes for x = 0..n-1 but not x = n.
# https://oeis.org/A230663

# Known terms:
#   2, 67, 3, 349, 79, 439, 21559, 14713, 13, 8123233, 223, 3468214093

=for comment

# One-line program:

use ntheory qw(:all); sub a { my $n = $_[0]; my $lo = 2; my $hi = 2*$lo; while (1) { my @terms = grep { !is_prime($_ + $n*($n+3)) } sieve_prime_cluster($lo, $hi, map { $_*($_+3) } 1 .. $n-1); return $terms[0] if @terms; $lo = $hi+1; $hi = 2*$lo; } }; $| = 1; for my $n (1..100) { print a($n), ", " } # ~~~~

=cut

# Lower-bounds:
#   a(16) > 58769259547504
#   a(17) > 7739161751110

# New terms:
#   a(13) = 1701300344203
#   a(14) = 11613197109589
#   a(15) = 19

use 5.036;
use ntheory qw(:all);

sub a ($n, $lo = 2, $hi = 2 * $lo) {

    while (1) {
        say ":: Sieving: [$lo, $hi]";
        my @terms = grep { !is_prime($_ + $n * ($n + 3)) } sieve_prime_cluster($lo, $hi, map { $_ * ($_ + 3) } 1 .. $n - 1);
        return $terms[0] if @terms;
        $lo = $hi + 1;
        $hi = int(1.5 * $lo);
    }
}

my $n  = 16;
my $lo = 58769259547504;
my $hi = int(1.5 * $lo);

say "a($n) = ", a($n, $lo, $hi);

__END__

isok(p, n) = for (k=0, n-1, if(!isprime(p + k*(k+3)), return(0))); return(!isprime(p + n*(n+3)));
a(n) = forprime(p=2, oo, if(isok(p, n), return(p))); \\ ~~~~
