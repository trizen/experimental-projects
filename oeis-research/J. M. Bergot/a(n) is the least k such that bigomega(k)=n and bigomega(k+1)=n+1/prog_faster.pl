#!/usr/bin/perl

# a(n) is the least k such that A001222(k)=n and A001222(k+1)=n+1.
# https://oeis.org/A322300

# Known terms:
#   1, 3, 26, 99, 495, 728, 1215, 6560, 309824, 1896128, 1043199, 15752960, 178149375, 399112191, 4226550272, 7219625984, 45990608895, 558743781375, 1565795778560

# Upper-bounds:
#   a(20) <= 271611680260095
#   a(20) <= 79776206553087

# New terms:
#   a(19) = 28996228218879
#   a(20) = 63685431525375
#   a(21) = 45922887663615

# New terms (2023):
#   a(22) = 1956754664980479
#   a(23) = 30987856352641023

# Lower-bounds:
#   a(22) > 1377686629908450
#   a(23) > 23131806279931653
#   a(24) > 5451438573140647

=for comment

# PARI/GP program:

generate(A, B, n, k) = A=max(A, 2^n); (f(m, p, n) = my(list=List()); if(n==1, forprime(q=max(p, ceil(A/m)), B\m, if(bigomega(m*q-1) == k, listput(list, m*q-1))), forprime(q=p, sqrtnint(B\m, n), list=concat(list, f(m*q, q, n-1)))); list); vecsort(Vec(f(1, 2, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n+1, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

use 5.036;
use ntheory qw(:all);

my $n = 24;

my $from = 1;
my $upto = 2;

#$from = "23131806279931653";
#$upto = int(1.001*$from);

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n+1, $from, $upto);

    foreach my $k (@$arr) {
        if (is_almost_prime($n, $k-1)) {
            printf("a(%s) = %s\n", $n, $k-1);
            exit;
        }
    }

    $from = $upto+1;
    $upto = int(1.001*$from);
}

__END__
Sieving range: (4398046511103, 8796093022206)
Sieving range: (8796093022207, 17592186044414)
Sieving range: (17592186044415, 35184372088830)
a(19) = 28996228218879
perl prog_faster.pl  94.55s user 5.66s system 99% cpu 1:40.79 total

Sieving range: (8796093022207, 17592186044414)
Sieving range: (17592186044415, 35184372088830)
Sieving range: (35184372088831, 70368744177662)
a(21) = 45922887663615
perl prog_faster.pl  40.60s user 2.70s system 99% cpu 43.594 total

Sieving range: (1913179763628255, 1932311561264537)
Sieving range: (1932311561264538, 1951634676877183)
Sieving range: (1951634676877184, 1971151023645955)
a(22) = 1956754664980479
perl prog_faster.pl  263.70s user 10.59s system 98% cpu 4:37.93 total
