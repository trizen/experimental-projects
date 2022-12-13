#!/usr/bin/perl

# a(n) is the smallest centered triangular number with exactly n distinct prime factors.
# https://oeis.org/A358928

# Known terms:
#   1, 4, 10, 460, 9010, 772210, 20120860, 1553569960, 85507715710

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = for(k=0, oo, my(t=3*k*(k+1)/2 + 1); if(omega(t) == n, return(t))); \\ ~~~~

=for comment

# All prime factors of a(n) are congruent to [1, 2, 5, 17, 19, 23, 31, 47, 49, 53] mod 60.

# Faster PARI/GP program (with primes in residue classes):

omega_centered_polygonals(A, B, n, k) = A=max(A, vecprod(primes(n))); (f(m, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), my(s=q%60); if(s==1 || s==2 || s==5 || s==17 || s==19 || s==23 || s==31 || s==47 || s==49 || s==53, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A, if (issquare((8*(v-1))/k + 1) && ((sqrtint((8*(v-1))/k + 1)-1)%2 == 0), listput(list, v))), if(v*r <= B, list=concat(list, f(v, r, j-1)))); v *= q))); list); vecsort(Vec(f(1, 2, n)));
a(n) =my(x=vecprod(primes(n)), y=2*x); while(1, my(v=omega_centered_polygonals(x, y, n, 3)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

sub a($n) {

    for(my $k = 1; ; ++$k) {

        my $t = divint(mulint(3*$k, $k+1), 2) + 1;

        #if (prime_omega($t) == $n) {
        if (is_omega_prime($n, $t)) {
            return $t;
        }
    }
}

foreach my $n (1..100) {
    say "a($n) = ", a($n);
}

__END__
a(9)  = 14932196985010
a(10) = 1033664429333260
a(11) = 197628216951078460
a(12) = 21266854897681220860
a(13) = 7423007155473283614010
