#!/usr/bin/perl

# Number of positive integers <= 10^n that are divisible by no prime exceeding 13.
# https://oeis.org/A106629

# If ψ(n,B) is the number of B-smooth <= n, then:
#
#   ψ(n,B) ~ 1/pi(B)! * Prod_{p prime <= B} log(x)/log(p)
#
# where pi(x) is the prime-counting function.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));

    foreach my $p (@$primes) {
        foreach my $n (@h) {
            my $t = $n * $p;
            if ($t <= $limit) {
                push @h, $t;
            }
        }
    }

    return \@h;
}

foreach my $k (0 .. 25) {
    my $h = smooth_numbers(Math::GMPz->new(10)**$k, primes(13));
    say "$k ", $#{$h} + 1;
}

__END__
0 1
1 10
2 62
3 242
4 733
5 1848
6 4106
7 8289
8 15519
9 27365
10 45914
11 73908
12 114831
13 173077
14 254065
15 364385
16 511985
17 706293
18 958460
19 1281500
20 1690506
21 2202871
22 2838489
23 3620013
24 4573071
25 5726533
26 7112760
27 8767880
28 10732089
29 13049906
30 15770500
31 18948010
32 22641849
33 26917042
34 31844560
