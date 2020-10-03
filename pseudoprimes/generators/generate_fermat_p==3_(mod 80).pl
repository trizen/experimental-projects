#!/usr/bin/perl

# Generate Fermat base-2 pseudoprimes where each prime factor is congruent to 3 (mod 80).

use 5.020;
use warnings;
use experimental qw(signatures);

use List::Util qw(shuffle);
use ntheory qw(forcomb forprimes kronecker divisors lucas_sequence factor_exp factor primes divisor_sum powmod);
use Math::Prime::Util::GMP qw(is_frobenius_pseudoprime vecprod binomial is_pseudoprime);

my %common_divisors;

forprimes {
    if (($_ % 80 == 3)) {
        foreach my $d (divisors($_ - 1)) {
            if (powmod(2, $d, $_) == 1) {
                push @{$common_divisors{$d}}, $_;
            }
        }
    }
} 1e9;

my $k = 3;
foreach my $arr (values %common_divisors) {

    my @nums = @$arr;
    next if (@nums < $k);

    forcomb {
        my $n = vecprod(@nums[@_]);

        if ($n > ~0) {
            say $n;
        }
    }
    scalar(@nums), $k;
}

__END__
4263739170243679206753787
1820034970687975620484907
522925572082528736632187
164853581396047908970027
68435117188079800987
