#!/usr/bin/perl

# Integers k such that k is equal to the sum of the nonprime proper divisors of k.
# https://oeis.org/A331805

# 9*10^12 < a(4) <= 72872313094554244192 = 2^5 * 109 * 151 * 65837 * 2101546957. - Giovanni Resta, Jan 28 2020

# Notice that:
#   65837 = 2^2 * 109 * 151 + 1
#   sigma(2^5 * 109 * 151 * 65837) / 2101546957 =~ 33.00003145254488 =~ 2^5 + 1

# Try to find terms, using combinations of primes: p * q * (2^k * p * q + 1) * s, where s is squarefree.

use 5.014;
use ntheory qw(:all);
use List::Util qw(uniq);
use Math::GMPz;

#use Math::AnyNum qw(:overload);

sub prime_sigma {
    my ($n) = @_;
    vecsum(uniq(factor($n)));
}

sub isok {
    my ($n) = @_;
    divisor_sum($n) - $n - prime_sigma($n) == $n;
}

my @factors;
my @primes = @{primes(200)};

forcomb {

    my ($x, $y) = @primes[@_];

    foreach my $k (1 .. 4) {
        my $z = (1 << $k) * $x * $y + 1;
        if (is_prime($z)) {
            push @factors, $x * $y * $z;
        }
    }
} scalar(@primes), 2;

foreach my $z (@factors) {
    my $orig_ps = prime_sigma($z);

    forsquarefree {
        my $r = $_;
        my $w = $z * $r;

        foreach my $k (1 .. 10) {

            my $v     = $w << $k;
            my $s     = divisor_sum($v);
            my $ratio = "$s" / "$v";

            $ratio < 2          or next;
            $ratio > 1.99999999 or next;

            #"$s" / "$v" > (2 - 1 / "$v"**(2 / 3)) or next;
            #"$s"/"$v" > 1.999999999 or next;

            my $ps = prime_sigma($v);
            say "z = $z ; v = $v -> ", $s - $ps, " with $ratio";

            foreach my $p (factor($s - $ps)) {

                my $u = ($v * $p);

                if (!ref($u) and $u > ~0) {
                    $u = Math::GMPz->new($v) * $p;
                }

                if ($u > 1e13 && isok($u)) {
                    say "\nFound: $u\n";

                    if ("$u" ne "72872313094554244192") {
                        die "New term: $u";
                    }
                }
            }
        }

    } 1e3;
}
