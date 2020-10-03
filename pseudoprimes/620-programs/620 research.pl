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

    forprimes {
        my $p = $_;
        $generated{$p} = 1;

        foreach my $d (divisors($p - kronecker($p, 5))) {
            #if (lucasmod($d, $p) == 0) {
            #if (lucas_sequence($p,

            my ($U, $V) = lucas_sequence($p, 1, -1, $d);

            #if ($U == 0 and $V==2) {
            #if ($V == 0) {
            #if (lucasmod($d, $p) == 0) {
            #if (fibmod($d, $p) == 0) {

            if ( $U == 0 or $V == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    } 1e5;

    foreach my $n(1..1e5) {
        my $p = random_prime(10**9);

        next if $generated{$p}++;

        foreach my $d (divisors($p - kronecker($p, 5))) {
            #if (lucasmod($d, $p) == 0) {
            #if (lucas_sequence($p,

            my ($U, $V) = lucas_sequence($p, 1, -1, $d);

            #if ($U == 0 and $V==2) {
            #if ($V == 0) {
            #if (lucasmod($d, $p) == 0) {
            #if (fibmod($d, $p) == 0) {

            if ($U == 0 or $V == 0) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    }


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
    fibmod($n - kronecker($n, 5), $n) == 0;
}

sub BPSW_primality_test ($n) {

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

    my ($Q, $D) = (1, 0);

    for (my $k = 2 ; ; ++$k) {
        $D = (-1)**$k * (2 * $k + 1);

        if (Math::GMPz::Rmpz_si_kronecker($D, $n) == -1) {
            $Q = (1 - $D) / 4;
            last;
        }
    }

    Math::GMPz::Rmpz_add_ui($d, $d, 2);

    my $s = Math::GMPz::Rmpz_scan1($d, 0);
    my $U1 = Math::GMPz::Rmpz_init_set_ui(1);

    my ($V1, $V2) = (Math::GMPz::Rmpz_init_set_ui(2), Math::GMPz::Rmpz_init_set_ui(1));
    my ($Q1, $Q2) = (Math::GMPz::Rmpz_init_set_ui(1), Math::GMPz::Rmpz_init_set_ui(1));

    foreach my $bit (split(//, substr(Math::GMPz::Rmpz_get_str($d, 2), 0, -$s - 1))) {

        Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);
        Math::GMPz::Rmpz_mod($Q1, $Q1, $n);

        if ($bit) {
            Math::GMPz::Rmpz_mul_si($Q2, $Q1, $Q);
            Math::GMPz::Rmpz_mul($U1, $U1, $V2);
            Math::GMPz::Rmpz_mul($V1, $V1, $V2);

            Math::GMPz::Rmpz_powm_ui($V2, $V2, 2, $n);
            Math::GMPz::Rmpz_sub($V1, $V1, $Q1);
            Math::GMPz::Rmpz_submul_ui($V2, $Q2, 2);

            Math::GMPz::Rmpz_mod($V1, $V1, $n);
            Math::GMPz::Rmpz_mod($U1, $U1, $n);
        }
        else {
            Math::GMPz::Rmpz_set($Q2, $Q1);
            Math::GMPz::Rmpz_mul($U1, $U1, $V1);
            Math::GMPz::Rmpz_mul($V2, $V2, $V1);
            Math::GMPz::Rmpz_sub($U1, $U1, $Q1);

            Math::GMPz::Rmpz_powm_ui($V1, $V1, 2, $n);
            Math::GMPz::Rmpz_sub($V2, $V2, $Q1);
            Math::GMPz::Rmpz_submul_ui($V1, $Q2, 2);

            Math::GMPz::Rmpz_mod($V2, $V2, $n);
            Math::GMPz::Rmpz_mod($U1, $U1, $n);
        }
    }

    Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);
    Math::GMPz::Rmpz_mul_si($Q2, $Q1, $Q);
    Math::GMPz::Rmpz_mul($U1, $U1, $V1);
    Math::GMPz::Rmpz_mul($V1, $V1, $V2);
    Math::GMPz::Rmpz_sub($U1, $U1, $Q1);
    Math::GMPz::Rmpz_sub($V1, $V1, $Q1);
    Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);

    if (Math::GMPz::Rmpz_congruent_ui_p($U1, 0, $n)) {
        return 1;
    }

    if (Math::GMPz::Rmpz_congruent_ui_p($V1, 0, $n)) {
        return 1;
    }

    for (1 .. $s) {

        Math::GMPz::Rmpz_mul($U1, $U1, $V1);
        Math::GMPz::Rmpz_mod($U1, $U1, $n);
        Math::GMPz::Rmpz_powm_ui($V1, $V1, 2, $n);
        Math::GMPz::Rmpz_submul_ui($V1, $Q1, 2);
        Math::GMPz::Rmpz_powm_ui($Q1, $Q1, 2, $n);

        if (Math::GMPz::Rmpz_congruent_ui_p($V1, 0, $n)) {
            return 1;
        }
    }

    return 0;
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

         if (BPSW_primality_test($n)) {
            die "Found a counter-example to BPSW: $n\n";
        }
    }


    }
);

#@pseudoprimes = sort {$a <=> $b} @pseudoprimes;

#say join(', ', @pseudoprimes);
