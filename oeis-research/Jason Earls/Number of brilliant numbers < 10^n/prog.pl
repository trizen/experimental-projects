#!/usr/bin/perl

# Count the number of Brilliant numbers < 10^n.

# Brilliant numbers are semiprimes such that both prime factors have the same number of digits in base 10.

# OEIS sequence:
#   https://oeis.org/A086846 --  Number of brilliant numbers < 10^n.

# See also:
#   https://rosettacode.org/wiki/Brilliant_numbers

#~ a(1) = 3
#~ a(2) = 10
#~ a(3) = 73
#~ a(4) = 241
#~ a(5) = 2504
#~ a(6) = 10537
#~ a(7) = 124363
#~ a(8) = 573928
#~ a(9) = 7407840
#~ a(10) = 35547994
#~ a(11) = 491316166
#~ a(12) = 2409600865
#~ a(13) = 34896253009
#~ a(14) = 174155363186
#~ a(15) = 2601913448896
#~ a(16) = 13163230391312
#~ a(17) = 201431415980418
#~ a(18) = 1029540512731472
#~ a(19) = ?
#~ a(20) = 82720372430619225

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub brilliant_numbers_count ($n) {

    my $count = 0;
    my $len   = length(sqrtint($n));

    foreach my $k (1 .. $len - 1) {
        my $pi = prime_count(powint(10, $k - 1), powint(10, $k) - 1);
        $count += binomial($pi, 2) + $pi;
    }

    my $min = powint(10, $len - 1);
    my $max = powint(10, $len) - 1;

    my $pi_min = prime_count($min);
    my $pi_max = prime_count($max);

    my $j = -1;

    forprimes {
        if ($_ * $_ <= $n) {
            $count += (($n >= $_ * $max) ? $pi_max : prime_count(divint($n, $_))) - $pi_min - ++$j;
        }
        else {
            lastfor;
        }
    } $min, $max;

    return $count;
}

foreach my $n (1 .. 18) {
    say "a($n) = ", brilliant_numbers_count(powint(10, $n) - 1);
}

__END__

# PARI/GP program for 10^n - 1:

a(n) = my(N=10^n-1, count=0, L=#digits(sqrtint(N))); for(k=1, L-1, count += binomial(primepi(10^k) - primepi(10^(k-1)) + 1, 2)); my(min = 10^(L-1), max = 10^L-1, pi_min = primepi(min), pi_max = primepi(max), j = 0); forprime(p = min, max, if(p*p <= N, count += if(N >= p*max, pi_max, primepi(N\p)) - pi_min - j; j+=1, break)); count; \\ ~~~~

# PARI/GP program for any n:

a(N) = my(count=0, L=#digits(sqrtint(N))); for(k=1, L-1, count += binomial(primepi(10^k) - primepi(10^(k-1)) + 1, 2)); my(min = 10^(L-1), max = 10^L-1, pi_min = primepi(min), pi_max = primepi(max), j = 0); forprime(p = min, max, if(p*p <= N, count += if(N >= p*max, pi_max, primepi(N\p)) - pi_min - j; j+=1, break)); count; \\ ~~~~
