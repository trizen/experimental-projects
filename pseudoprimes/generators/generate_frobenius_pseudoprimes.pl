#!/usr/bin/perl

# Generate Frobenius pseudoprimes to the polynomial x^2 + 5x + 5.
# No known such pseudoprime `n` is known with `legendre(n,5) = -1`.

use 5.020;
use warnings;
use experimental qw(signatures);

use List::Util qw(shuffle);
use ntheory qw(forcomb forprimes kronecker divisors lucas_sequence factor_exp factor);
use Math::Prime::Util::GMP qw(is_frobenius_pseudoprime vecprod binomial);

sub rad ($n) {
    vecprod(map{$_->[0]}factor_exp($n));
}

sub gpf ($n) {
    (factor($n))[-1];
}

sub fermat_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    forprimes {
        my $p = $_;
       #foreach my $d (divisors($p - kronecker($p, 5))) {
       foreach my $d(divisors($p-kronecker($p, 5))) {

            next if ($d == 1);
            next if ($d+1 >= $p);

             #if ((lucas_sequence($p, -5, 5, $d))[1] == 2 and
             my ($U, $V) = (lucas_sequence($p, -5, 5, $d));
             #if ($U == 0 and $V == 2) {

             #if ($U == 0 and $V == 2) {
             if ($U == 0 and $V == 2) {
                #say join ' ', factor $d;
                push @{$common_divisors{rad($d)}}, $p;
                #push @{$common_divisors{ vecsum todigits($p, $d) }}, $p;
            }
        }
    } $limit;

    warn ":: Generating combinations...\n";

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
    1e7,
    sub ($n) {

       #if  is_fermat_pseudoprime($n, 2) || die "error for n=$n";

        #if (kronecker($n, 5) == -1) {
        #    if (is_fibonacci_pseudoprime($n)) {
        #        die "Found a special pseudoprime: $n = prod(@f)";
        #    }
        #}

        #push @pseudoprimes, $n;
        #say $n if ($n > 1e15 and is_pseudoprime($n, 2) and !$seen{$n}++);

        if (is_frobenius_pseudoprime($n, -5, 5)) {

                say $n if !$seen{$n}++;

                if (kronecker($n,5) == -1) {
                    die "Counter-example: $n";
                }
            }
    }
);
