#!/usr/bin/perl

# a(n) is the smallest centered square number with exactly n distinct prime factors.
# https://oeis.org/A359234

# Previously known terms:
#   1, 5, 85, 1105, 99905, 2339285, 294346585, 29215971265, 4274253515545

# New terms found:
#   a(9)  = 135890190846085
#   a(10) = 14289540733429585
#   a(11) = 10285257499051999685
#   a(12) = 659442750659021626765
#   a(13) = 386961420250791449193065
#   a(14) = 10019680253112694448155885
#   a(15) = 7190322949201929673798425205
#   a(16) = 944550762877225960238953138865

# Terms:
#   1, 5, 85, 1105, 99905, 2339285, 294346585, 29215971265, 4274253515545, 135890190846085, 14289540733429585, 10285257499051999685, 659442750659021626765, 386961420250791449193065, 10019680253112694448155885, 7190322949201929673798425205, 944550762877225960238953138865

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = for(k=0, oo, my(t=2*k*k + 2*k + 1); if(omega(t) == n, return(t))); \\ ~~~~

=for comment

# All the prime factors of a(n) are congruent to 1 mod 4.

# Faster PARI/GP program (with primes in residue classes):

omega_centered_polygonals(A, B, n, k) = A=max(A, vecprod(primes(n))); (f(m, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), my(s=q%4); if(s==1, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A, if (issquare((8*(v-1))/k + 1) && ((sqrtint((8*(v-1))/k + 1)-1)%2 == 0), listput(list, v))), if(v*r <= B, list=concat(list, f(v, r, j-1)))); v *= q))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=vecprod(primes(n)), y=2*x); while(1, print([x,y]); my(v=omega_centered_polygonals(x, y, n, 4)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Specialized version:

omega_centered_square_numbers(A, B, n) = A=max(A, vecprod(primes(n))); (f(m, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(q%4==1, my(v=m*q, r=nextprime(q+1)); while(v <= B, if(j==1, if(v>=A, if (issquare((8*(v-1))/4 + 1) && ((sqrtint((8*(v-1))/4 + 1)-1)%2 == 0), listput(list, v))), if(v*r <= B, list=concat(list, f(v, r, j-1)))); v *= q))); list); vecsort(Vec(f(1, 2, n)));
a(n) = if(n==0, return(1)); my(x=vecprod(primes(n)), y=2*x); while(1, my(v=omega_centered_square_numbers(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

sub a($n) {

    for(my $k = 1; ; ++$k) {

        my $t = divint(mulint(4*$k, $k+1), 2) + 1;

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
a(1) = 5
a(2) = 85
a(3) = 1105
a(4) = 99905
a(5) = 2339285
a(6) = 294346585
a(7) = 29215971265
a(8) = 4274253515545
a(9) = 135890190846085
