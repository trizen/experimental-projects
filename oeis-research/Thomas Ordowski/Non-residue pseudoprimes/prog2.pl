#!/usr/bin/perl



use 5.014;
use strict;
use ntheory qw(:all);

# 3277, 703, 7813, 325, 2047, 85, 91, 343, 1271, 15, 931

my @cache = (3, 7, 23, 71, 311, 479, 1559, 5711, 10559, 18191, 31391, 422231, 701399, 366791, 3818929, 9257329, 22000801, 36415991, 48473881, 175244281, 120293879);

sub non_residue {
    my ($n, $q) = @_;

    for (my $p = 2; ; $p = next_prime($p)) {

        if ($p > $q) {
            return -1;
        }

        sqrtmod($p, $n) // return $p;
    }
}

sub foo {
    my ($n) = @_;

    my $res;
    my $p = nth_prime($n);

    for(my $k = $cache[$n-1]*$cache[$n-1]; ; $k+=2) {

        is_prime($k) && next;

        my $q = non_residue($k, $p);

        if ($p == $q and powmod($q, ($k-1)>>1, $k) == $k-1) {
            return $k;
        }
    }

    return $res;
}

foreach my $n(1..10) {
    say "a($n) = ", foo($n);
}

__END__
func f(n) {
    for k in (1..1e6) {
        sqrtmod(prime(k), n) || return prime(k)
    }
}

var cache = [
func g(n) {
    var p = prime(n)
    for k in (cache[n-1]**2 .. 1e11 `by` 2) {
        if (!k.is_prime) {
            var q = f(k)
            if (p==q && powmod(q, (k-1)/2, k)==(k-1)) {
                return k
            }
        }
    }
}


say g(1)
say g(2)
say g(3)
say g(4)
say g(5)
say g(6)

__END__
say 100.of{f(3+_)}

__END__

func f(n) {
    sigma(n) * n.factor_sum{|p,e|
        1/(p**e - 1)
    }
}

func g(n) {
    n.prime_power_divisors.sum{|d|
        euler_phi(n/d)
    }
}

say 20.of(f)
#say 20.of(g)

#assert_eq(10000.of(f), 10000.of(g))
#10000.of(g)

#~ with q = A020649(k), such that A020649(k) = prime(n),
