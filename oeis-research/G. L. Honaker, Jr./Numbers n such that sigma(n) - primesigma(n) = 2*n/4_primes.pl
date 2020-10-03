#!/usr/bin/perl

# Integers k such that k is equal to the sum of the nonprime proper divisors of k.
# https://oeis.org/A331805

# 9*10^12 < a(4) <= 72872313094554244192 = 2^5 * 109 * 151 * 65837 * 2101546957. - Giovanni Resta, Jan 28 2020

# Notice that:
#   65837 = 2^2 * 109 * 151 + 1
#   sigma(2^5 * 109 * 151 * 65837) / 2101546957 =~ 33.00003145254488 =~ 2^5 + 1

# Try to generate solutions, using 4 small prime factors.

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

my @primes = @{primes(1000,2000)};

foreach my $x (@primes) {

    foreach my $k (1 .. 10) {

        my $t = (1 << $k) * $x + 1;
        is_prime($t) || next;

        foreach my $y (@primes) {

            foreach my $i (1 .. 10) {

                my $z = (1 << $i) * $y + 1;
                is_prime($z) || next;

                foreach my $j (1 .. 21) {

                    my $v = (1 << $j) * $x * $y * $t * $z;

                    if ($v > ~0) {
                        $v = Math::GMPz::Rmpz_init_set_ui($x);
                        Math::GMPz::Rmpz_mul_ui($v, $v, $y);
                        Math::GMPz::Rmpz_mul_ui($v, $v, $t);
                        Math::GMPz::Rmpz_mul_ui($v, $v, $z);
                        Math::GMPz::Rmpz_mul_2exp($v, $v, $j);
                    }

                    my $s     = divisor_sum($v);
                    my $ratio = "$s" / "$v";

                    $ratio < 2 or next;
                    $ratio > 1.9999 or next;

                    #"$s" / "$v" > (2 - 1 / "$v"**(2 / 3)) or next;
                    #"$s"/"$v" > 1.999999999 or next;

                    my $ps = $x + $y + $t + $z;
                    say "[$x,$y,$t,$z], $v, [$k, $i, $j] -> ", $s - (2 + $ps), " with $ratio";

                    foreach my $p (factor($s - (2 + $ps))) {

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
            }
        }
    }
}
