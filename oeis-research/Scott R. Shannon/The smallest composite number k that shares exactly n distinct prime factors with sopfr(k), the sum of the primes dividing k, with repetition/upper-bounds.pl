#!/usr/bin/perl

# The smallest composite number k that shares exactly n distinct prime factors with sopfr(k), the sum of the primes dividing k, with repetition.
# https://oeis.org/A372524

# Known terms:
#   6, 4, 30, 1530, 40530, 37838430, 900569670

# New terms:
#   a(7) = 781767956970

# Upper-bounds:
#   a(8) <= 188166439641180
#   a(9) <= 447933788867835270

# Conjectured lower-bounds:
#   a(9) > 10^9 * primorial(prime(9))

use 5.036;
use ntheory qw(:all);
use List::Util qw(sum);

my $n = 10;
my $prefix_prod = pn_primorial($n);
my $prefix_sum = vecsum(factor($prefix_prod));

forfactored {

    my $gcd = gcd(sum(@_) + $prefix_sum, $prefix_prod * $_);

    if ($gcd >= $prefix_prod and is_omega_prime($n, $gcd)) {
        say $_ * $prefix_prod;
    }
} 1e10;

__END__

# Upper-bounds for n = 7:

781767956970
1563629337270
2345490717570
4691074858470
5472936238770
6254797619070
7036658999370
8600381759970
11067171695580
12509688661470
14073411422070
14731312806210
16157060029110
16217841860220
17104646739180
17200856943270
18242953348620

# Upper-bounds for n = 8:

188166439641180
1505342244986580
1881678189370980

# Upper-bounds for n = 9:

447933788867835270
