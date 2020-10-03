#!/usr/bin/perl

# Searched up to: 15733

# https://oeis.org/A323353

# Found: 24547

use 5.014;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(lucasu is_prob_prime);

foreach my $n(24548..1e9) {
    say "Testing: $n";

    if (is_prob_prime(lucasu(3, -8, $n))) {
        say "Found: $n";

        if ($n > 24547) {
            die "!!!Found new term!!! -- $n\n";
        }
    }
}

__END__
    var a = [2, 3, 7, 11, 13, 73, 401, 421, 677, 3673, 4903]

a.each {|n|
    say lucasu(3, -8, n).is_prob_prime
}


__END__
# Daniel "Trizen" Șuteu
# Date: 08 January 2019
# https://github.com/trizen

# a(n) = smallest positive integer k such that n divides binomial(n+k, k).

# Sequence inspired by the Kempner numbers:
#   https://oeis.org/A002034

# Prime power identity:
#   a(p^k) = p^k * (p^k - 1), for p^k a prime power.

# Lower bound formula for a(n). Let:
#   f(n, p^k) = p^k * (p^k - n/p^k)

# if n = p1^e1 * p2^e2 * ... * pu^eu,
# then a(n) >= max( f(n,p1^e1), f(n,p2^e2), ..., f(n,pu^eu) ).

use 5.020;
use warnings;
use experimental qw(signatures);

use ntheory qw(factor_exp);
use Math::AnyNum qw(binomial is_div ipow max factorial prod rising_factorial falling_factorial);

sub f ($n) {
    for (my $k = 1 ; ; ++$k) {
        if (is_div(falling_factorial($n, $k), $n)) {
            return $k;
        }
    }
}

sub g($n) {    # g(n) <= f(n)
    max(map {
        my $pk = ipow($_->[0], $_->[1]);
        $pk * ($pk - $n / $pk)
    } factor_exp($n));
}

#say "f(n) = [", join(", ", map { f($_) } 2 .. 201), "]";
#say "g(n) = [", join(", ", map { g($_) } 2 .. 201), "]";

foreach my $n(2..20) {
    my $k = f($n);

    say "f($n) = $k";

    #rising_factorial($n, $k) == prod($n .. $n+$k-1) or die "error";
    #falling_factorial($n, $k) == prod($n-$k+1 .. $n) or die "error";

    #say "f($n) = ", $k, ' -> ', (prod($n-$k..$n)/factorial($k));

    #binomial($n + $k, $k) == prod($n+1..$n+$k)/factorial($k) or die "error";
}

__END__
f(n) = [2, 6, 12, 20, 3, 42, 56, 72, 15, 110, 6, 156, 35, 12, 240, 272, 63, 342, 12, 33, 99, 506, 40, 600, 143, 702, 21, 812, 24, 930]
g(n) = [2, 6, 12, 20, 3, 42, 56, 72, 15, 110, 4, 156, 35, 10, 240, 272, 63, 342,  5, 28, 99, 506, 40, 600, 143, 702, 21, 812, -5, 930]
