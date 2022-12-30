#!/usr/bin/perl

# a(n) is the smallest centered square number with exactly n prime factors (counted with multiplicity).
# https://oeis.org/A359235

# Previously known terms:
#   1, 5, 25, 925, 1625, 47125, 2115625, 4330625, 83760625, 1049140625, 6098828125, 224991015625, 3735483578125, 329495166015625

# New terms found:
#   a(14) = 8193863401953125
#   a(15) = 7604781494140625
#   a(16) = 216431299462890625
#   a(17) = 148146624615478515625
#   a(18) = 25926420587158203125
#   a(19) = 11071085186929931640625

# Terms:
#   1, 5, 25, 925, 1625, 47125, 2115625, 4330625, 83760625, 1049140625, 6098828125, 224991015625, 3735483578125, 329495166015625, 8193863401953125, 7604781494140625, 216431299462890625, 148146624615478515625, 25926420587158203125, 11071085186929931640625

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = for(k=0, oo, my(t=2*k*k + 2*k + 1); if(bigomega(t) == n, return(t))); \\ ~~~~

=for PARI/GP

bigomega_centered_square_numbers(A, B, n) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p,ceil(A/m)), B\m, if(q%4==1, my(t=m*q); if(issquare((8*(t-1))/4 + 1) && ((sqrtint((8*(t-1))/4 + 1)-1)%2 == 0), listput(list, t)))), forprime(q=p, sqrtnint(B\m, n), if(q%4==1, my(t=m*q); if(ceil(A/t) <= B\t, list=concat(list, f(t, q, n-1)))))); list); vecsort(Vec(f(1, 2, n)));
a(n) = if(n==0, return(1)); my(x=2^n, y=2*x); while(1, my(v=bigomega_centered_square_numbers(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

sub a($n) {
    for(my $k = 0; ;++$k) {
        my $v = divint(mulint(4*$k, ($k + 1)), 2) + 1;
        if (is_almost_prime($n, $v)) {
            return $v;
        }
    }
}

foreach my $n(1..100) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 5
a(2) = 25
a(3) = 925
a(4) = 1625
a(5) = 47125
a(6) = 2115625
a(7) = 4330625
a(8) = 83760625
a(9) = 1049140625
a(10) = 6098828125
a(11) = 224991015625
a(12) = 3735483578125
a(13) = 329495166015625
a(14) = 8193863401953125
