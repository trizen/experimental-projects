#!/usr/bin/perl

# Integers k such that k is equal to the sum of the nonprime proper divisors of k.
# https://oeis.org/A331805

# 9*10^12 < a(4) <= 72872313094554244192 = 2^5 * 109 * 151 * 65837 * 2101546957. - Giovanni Resta, Jan 28 2020

# Notice that:
#   65837 = 2^2 * 109 * 151 + 1
#   sigma(2^5 * 109 * 151 * 65837) / 2101546957 =~ 33.00003145254488 =~ 2^5 + 1

# Also:
#   log_3(72872313094554244192) =~ 41.6300098  (coincidence?)

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

#say isok(72872313094554244192);

forsquarefree {

    my $r = $_;

    foreach my $k (1..4) {

        my $t = (1 << $k) * $r + 1;
        is_prime($t) || next;

        foreach my $j ($k .. 2 * $k + 1) {

            my $v = (1 << $j) * $r * $t;

            if ($v > ~0) {
                $v = Math::GMPz::Rmpz_init_set_ui($r);
                Math::GMPz::Rmpz_mul_ui($v, $v, $t);
                Math::GMPz::Rmpz_mul_2exp($v, $v, $j);
            }

            my $s = divisor_sum($v);
            my $ratio = "$s"/"$v";

            $ratio < 2 or next;
            $ratio > 1.9999 or next;

            #"$s" / "$v" > (2 - 1 / "$v"**(2 / 3)) or next;
            #"$s"/"$v" > 1.999999999 or next;

            my $ps = prime_sigma($r);
            say "$r, $v, [$k, $j] -> ", $s - (2 + $t + $ps), " with $ratio";

            foreach my $p (factor($s - (2 + $t + $ps))) {

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
} 1,1e9;
