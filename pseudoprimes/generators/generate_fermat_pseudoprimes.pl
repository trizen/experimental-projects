#!/usr/bin/perl

# 2, 3, 5, 7, 11, 17, 19, 29, 41, 71, 179, 181, 239, 419, 701, 839, 881, 1259, 1871, 2161, 2521, 4159, 5039, 7561, 10079, 13441, 13859, 20161, 22679, 30241, 35281, 45361, 55439, 65519, 110879, 138599, 151201, 166319, 226799, 262079, 327599, 332641, 415801, 665279, 831599, 942479, 1081079, 1441439, 2827439, 3326399, 4324321, 6320159, 10533599, 11309759, 12972959, 14414401, 21067201, 23284799, 24504479, 32432399, 41081041, 43243201, 61261199, 68468399, 82162079, 108107999, 110270161, 136936799, 164324161, 183783601, 248648401, 273873599, 302702401, 367567201, 410810399, 627026399, 698377679, 735134399, 1074427199, 1102701599, 1163962801, 1396755359, 1470268801, 2205403199, 2818015199, 3381618241, 3859455599, 4227022799, 4655851201, 7558911361, 8031343319, 8147739599, 8454045601, 9777287521, 12681068399, 12681068401, 13967553601, 20951330399, 29331862561, 32125373279

use 5.020;
use warnings;
use experimental qw(signatures);

use List::Util qw(shuffle);
use ntheory qw(forcomb forprimes kronecker divisors lucas_sequence factor_exp factor primes divisor_sum powmod);
use Math::Prime::Util::GMP qw(is_frobenius_pseudoprime vecprod binomial is_pseudoprime);

sub gpf ($n) {
    (factor($n))[-1];
}

sub rad ($n) {
    vecprod(map{$_->[0]}factor_exp($n));
}

sub fermat_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    foreach my $p(
   shuffle(@{primes(100000)}),
) {

    next if divisor_sum($p-1,0) > 1e6;

        foreach my $d (divisors($p - 1)) {
            if (powmod(2, $d, $p) == 1) {
                #say join ' ', factor $d;
                my @f = (factor($d));
                push @{$common_divisors{$f[rand @f]}}, $p;
                #push @{$common_divisors{ vecsum todigits($p, $d) }}, $p;
            }
        }
    }

    #$limit;

    foreach my $arr (values %common_divisors) {

        my $l = scalar(@$arr);
        $arr = [shuffle @$arr];

        foreach my $k (2 .. $l) {

            binomial($l, $k) > 1e3 and last;

            forcomb {
               # my $n = prod(@{$arr}[@_]);
               # $callback->($n) #if !$seen{$n}++;
                my $n = vecprod(@{$arr}[@_]);

                if ($n > ~0) {
                    $callback->($n);
                }
            } $l, $k;
        }
    }
}

sub is_fermat_pseudoprime ($n, $base) {
    powmod($base, $n - 1, $n) == 1;
}

sub is_fibonacci_pseudoprime($n) {
    (lucas_sequence($n, 1, -1, $n - kronecker($n, 5)))[0] == 0;
}

my %seen;

fermat_pseudoprimes(
    20_000,
    sub ($n) {

       #if  is_fermat_pseudoprime($n, 2) || die "error for n=$n";

        #if (kronecker($n, 5) == -1) {
        #    if (is_fibonacci_pseudoprime($n)) {
        #        die "Found a special pseudoprime: $n = prod(@f)";
        #    }
        #}

        #push @pseudoprimes, $n;
        say $n if (is_pseudoprime($n, 2) and !$seen{$n}++);
    }
);
