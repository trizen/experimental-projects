#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 22 September 2018
# https://github.com/trizen

# A new algorithm for generating Fibonacci pseudoprimes.

# See also:
#   https://oeis.org/A081264 -- Odd Fibonacci pseudoprimes.
#   https://oeis.org/A212424 -- Frobenius pseudoprimes with respect to Fibonacci polynomial x^2 - x - 1.

# For more info, see:
#   https://trizenx.blogspot.com/2018/08/investigating-fibonacci-numbers-modulo-m.html

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(fibmod prod powmod lucasmod isqrt);
use ntheory qw(forcomb forprimes kronecker divisors factor_exp divisor_sum euler_phi lucas_sequence random_prime is_square_free);

sub find_D {
    my ($n) = @_;

    return 1 if ($n % 5) == 2;
    return 1 if ($n % 5) == 3;

    for (my $k = 2; ; ++$k) {
        if (kronecker($n, $k*$k+4) == -1) {
            return $k;
        }
    }
}

sub fibonacci_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    #~ #forprimes {
    #~ while (<>) {

        #~ my (undef, $p) = split(' ', $_);
        #~ $p = Math::AnyNum->new($p);
        #~ $p || next;

        #~ say $p;

        #~ #my $p = $_;
        #~ foreach my $d (divisors($p - kronecker($p, 5))) {
            #~ if (lucasmod($d, $p) == 0) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ } #$limit;

    #forprimes {

    my %generated;

    my $r = 1;#random_prime(1e7);

    forprimes {
        my $p = $_;
        $generated{$p} = 1;

        foreach my $d (divisors($p - kronecker($p, 5))) {
            #if (lucasmod($d, $p) == 0) {
            #if (lucas_sequence($p,

            my ($U, $V) = lucas_sequence($p, find_D($p), -1, $d);

            #if ($U == 0 and $V==2) {
            #if ($V == 0) {
            #if (lucasmod($d, $p) == 0) {
            #if (fibmod($d, $p) == 0) {

            #if ( $U == 0 or $V == 0) {
            #if ($U == 0) {#
            if ($U == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    } $r, $r+1e7;

    while (<>) {

        my (undef, $p) = split(' ', $_);

        $p || next;
        next if $generated{$p}++;
        $p = Math::GMPz->new($p);

        say $p;

        #my $p = $_;
        foreach my $d (divisors($p - kronecker($p, 5))) {

            my ($U, $V) = lucas_sequence($p, find_D($p), -1, $d);

            #if ($U == 0 and $V==2) {
            #if ($V == 0) {
            #if (lucasmod($d, $p) == 0) {
            #if (fibmod($d, $p) == 0) {

            if ($U == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    }


    #~ foreach my $n(1..1e5) {
        #~ my $p = random_prime(10**8);

        #~ next if $generated{$p}++;

        #~ foreach my $d (divisors($p + 1)) {
            #~ #if (lucasmod($d, $p) == 0) {
            #~ #if (lucas_sequence($p,

            #~ my ($U, $V) = lucas_sequence($p, find_D($p), -1, $d+1);

            #~ #if ($U == 0 and $V==2) {
            #~ #if ($V == 0) {
            #~ #if (lucasmod($d, $p) == 0) {
            #~ #if (fibmod($d, $p) == 0) {

            #~ if ($U == 0) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ }


    say "Found ", scalar(keys%common_divisors), " relations";

    my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = $#{$arr} + 1;

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                $callback->($n, @{$arr}[@_]) if !$seen{$n}++;
            } $l, $k;
        }
    }
}

sub is_fibonacci_pseudoprime($n) {
    my ($U) = lucas_sequence($n, 1, -1, $n - kronecker($n, 5));

    $U == 0;
}

sub PSW_primality_test ($n) {

    $n = Math::GMPz->new("$n");

    return 0 if Math::GMPz::Rmpz_cmp_ui($n, 1) <= 0;
    return 1 if Math::GMPz::Rmpz_cmp_ui($n, 2) == 0;
    return 0 if Math::GMPz::Rmpz_perfect_power_p($n);

    my $d = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init_set_ui(2);

    # Fermat base-2 test
    Math::GMPz::Rmpz_sub_ui($d, $n, 1);
    Math::GMPz::Rmpz_powm($t, $t, $d, $n);
    Math::GMPz::Rmpz_cmp_ui($t, 1) and return 0;

    # Find P such that kronecker(n, P^2 + 4) = -1.
    my $P;
    for (my $k = 1 ; ; ++$k) {
        if (Math::GMPz::Rmpz_kronecker_ui($n, $k * $k + 4) == -1) {
            $P = $k;
            last;
        }
    }

    # If LucasU(P, -1, n+1) = 0 (mod n), then n is probably prime.
    (lucas_sequence($n, $P, -1, $n + 1))[0] == 0;
}

#my @pseudoprimes;

fibonacci_pseudoprimes(
    10_000,
    sub ($n, @f) {

        if (is_fibonacci_pseudoprime($n)) {
            say "Fibonacci pseudoprime: $n";
        }
        else {
            #if (is_square_free($n)) {
                warn "Not a fib: $n\n";
            #}
        }

            #~ say "Found a pseudoprime: $n";
            #~ #or die "Not a Fibonacci pseudoprime: $n";

        #~ #say join(' * ', @f), " = $n";
       #~ # push @pseudoprimes, $n;
    #~ }else {
        #~ #warn "Not a fibonacci: $n\n";
    #~ }

    if (powmod(2, $n-1, $n) == 1) {
        warn "Found a Fermat pseudoprime: $n\n";

        if (kronecker($n, 5) == -1) {
            #if (powmod(2, $n - 1, $n) == 1) {
                die "\n\n**** Found a special pseudoprime: $n with factors (@f) *** \n\n";
            #}
        }

         if (PSW_primality_test($n)) {
            die "Found a counter-example to PSW: $n\n";
        }
    }


    }
);

#@pseudoprimes = sort {$a <=> $b} @pseudoprimes;

#say join(', ', @pseudoprimes);
