#!/usr/bin/env perl

# Daniel Suteu (with assistance from Claude AI and Google Gemini)
# Date: 26 November 2026
# https://oeis.org/A353409

# Smallest Fermat overpseudoprime to base 2 with exactly n distinct prime factors (OEIS A141232).
#
# Requires Math::GMPz, Math::Prime::Util and Math::Prime::Util::GMP.
#
# How the search works
# --------------------
# An overpseudoprime n = prod p^e (base 2) is a Fermat pseudoprime whose prime powers all
# have the same multiplicative order lambda = ord_{p^e}(2), with lambda | n-1.  Every such
# prime p is a primitive prime divisor of 2^lambda - 1 (ord_p(2) = lambda exactly), so
# p == 1 (mod lambda); then n == 1 (mod lambda) comes for free, and *any* product of
# k >= 2 distinct primes of
#
#     S_lambda = { p prime : ord_p(2) = lambda }
#
# is an overpseudoprime.  A prime power p^e with e >= 2 only makes n larger (p already
# has the right order), so the smallest term with k distinct prime factors is
#
#     a(k) = min over lambda of  (the product of the k smallest primes of S_lambda).
#
# Hence the search runs over lambda (not over a tree of primes):
#
#   * the primes of S_lambda are p = j*lambda + 1 (j even when lambda is odd), and they
#     are tested in increasing order with  2^lambda == 1 (mod p),  2^(lambda/r) != 1 (mod p)
#     for the primes r | lambda,  and a primality test (only done for the rare hits);
#   * the shared upper bound B is lowered to (n - 1) whenever a smaller term is found;
#   * lambda is limited by the product of the k smallest allowed values j*lambda + 1 <= B;
#   * the next prime is limited by  q*(q+s)*(q+2s)*... <= B / (product found so far)  (s is
#     the progression step), which is the only place where the scan can become long: the
#     last prime may be as large as B / (product of the other k-1);
#   * when the scan would be long, the cyclotomic number Phi_lambda(2) is used instead
#     (it is the product of the primes of S_lambda, up to the primes of lambda): the primes
#     found so far are divided out, and the cofactor is either 1 (dead), a prime (it is the
#     last prime, or dead) or is factored with Math::Prime::Util::GMP, which gives the
#     remaining primes of S_lambda at once;
#   * doubling bound B: a pass with the bound B finds the smallest term <= B (if any).

use v5.36;
use strict;
use warnings;

use Math::GMPz             qw(:mpz);
use Math::Prime::Util      qw(factor_exp powmod is_prime divint);
use Math::Prime::Util::GMP ();

sub fermat_overpsp_base2_smallest ($factor_count) {

    die "n must be an integer >= 2\n" if (!defined($factor_count) || $factor_count < 2);
    $factor_count = 0 + $factor_count;

    my $MAX_NATIVE_STEP = 1.7e19;
    my $MAX_SCAN_STEPS  = 5000;
    my $MAX_FACTOR_BITS = 128;

    my $bound     = Rmpz_init();
    my $log_bound = 0;
    my $best      = Rmpz_init();
    my $has_best  = 0;

    my ($prod, $cofactor, $num, $den, $tmp1, $tmp2) = map { Rmpz_init() } 1 .. 6;
    my $factor_z = Rmpz_init();
    my $cand_z   = Rmpz_init();

    my sub mpz_log ($z) {
        my $digits = Rmpz_get_str($z, 10);
        my $len    = length($digits);
        return log($digits) if $len <= 15;
        return log(substr($digits, 0, 15)) + ($len - 15) * log(10);
    }

    my sub set_bound ($z) {
        Rmpz_set($bound, $z);
        $log_bound = mpz_log($bound);
    }

    my sub record_candidate ($n) {
        return if Rmpz_cmp($n, $bound) > 0;
        Rmpz_set($best, $n);
        $has_best = 1;
        Rmpz_sub_ui($tmp1, $n, 1);
        set_bound($tmp1);
    }

    my sub next_prime_limit ($rem, $step, $log_prod) {
        my $target = $log_bound - $log_prod + 1e-9;
        return exp($target) + 1 if $rem == 1;

        my $q = exp($target / $rem) - 0.5 * ($rem - 1) * $step;
        $q = 1.0 if $q < 1.0;
        my $lo = 1.0;
        my $hi = exp($target / $rem) + 1.0;

        for (1 .. 25) {
            my ($f, $df) = (-$target, 0.0);
            for my $i (0 .. $rem - 1) {
                my $term = $q + $i * $step;
                $f  += log($term);
                $df += 1.0 / $term;
            }

            if (abs($f) <= 1e-12) {
                $hi = $q;
                last;
            }

            if   ($f < 0) { $lo = $q if $q > $lo }
            else          { $hi = $q if $q < $hi }

            my $next = ($df > 0) ? ($q - $f / $df) : (0.5 * ($lo + $hi));
            if ($next <= $lo || $next >= $hi) {
                $next = 0.5 * ($lo + $hi);
            }

            last if abs($next - $q) <= 1e-7 * ($q > 1.0 ? $q : 1.0);
            $q  = $next;
            $hi = $q if $f > 0 && $q < $hi;
        }

        return (($hi > $q ? $hi : $q) + 1);
    }

    my sub reduced_cyclotomic ($lambda, $lam_primes, $found_primes) {
        my $num_lam_primes = scalar(@$lam_primes);

        Rmpz_set_ui($num, 1);
        Rmpz_set_ui($den, 1);

        foreach my $mask (0 .. (1 << $num_lam_primes) - 1) {
            my ($div, $odd_bits) = ($lambda, 0);
            foreach my $i (0 .. $num_lam_primes - 1) {
                if (($mask >> $i) & 1) {
                    $div = divint($div, $lam_primes->[$i]);
                    ++$odd_bits;
                }
            }
            Rmpz_set_ui($tmp1, 1);
            Rmpz_mul_2exp($tmp1, $tmp1, $div);
            Rmpz_sub_ui($tmp1, $tmp1, 1);
            if   ($odd_bits & 1) { Rmpz_mul($den, $den, $tmp1) }
            else                 { Rmpz_mul($num, $num, $tmp1) }
        }

        Rmpz_divexact($cofactor, $num, $den);

        foreach my $p (@$lam_primes, @$found_primes) {
            Rmpz_set_str($factor_z, "$p", 10);
            while (Rmpz_divisible_p($cofactor, $factor_z)) {
                Rmpz_divexact($cofactor, $cofactor, $factor_z);
            }
        }
    }

    my sub resolve_by_cofactor ($lambda, $lam_primes, $found_primes, $force) {
        reduced_cyclotomic($lambda, $lam_primes, $found_primes);

        return 1 if Rmpz_cmp_ui($cofactor, 1) == 0;

        my $rem     = $factor_count - scalar(@$found_primes);
        my $cof_str = Rmpz_get_str($cofactor, 10);

        if (is_prime($cof_str)) {
            if ($rem == 1) {
                Rmpz_mul($tmp2, $prod, $cofactor);
                record_candidate($tmp2);
            }
            return 1;
        }

        return 0 if !$force && Rmpz_sizeinbase($cofactor, 2) > $MAX_FACTOR_BITS;

        my (%seen, @cof_factors);
        foreach my $f (Math::Prime::Util::GMP::factor($cof_str)) {
            push @cof_factors, Rmpz_init_set_str($f, 10) if !$seen{$f}++;
        }

        return 1 if @cof_factors < $rem;

        @cof_factors = sort { Rmpz_cmp($a, $b) } @cof_factors;

        Rmpz_set($tmp2, $prod);
        Rmpz_mul($tmp2, $tmp2, $cof_factors[$_]) for 0 .. $rem - 1;
        record_candidate($tmp2);

        return 1;
    }

    my sub search_pass () {

      LAMBDA: for (my $lambda = 2 ; ; ++$lambda) {

            my $min_log = 0;
            $min_log += log($_ * $lambda + 1) for 1 .. $factor_count;
            last if $min_log > $log_bound + 1e-9;

            my $step = ($lambda & 1) ? 2 * $lambda : $lambda;

            if ($step != $lambda) {
                my $even_min_log = 0;
                $even_min_log += log($_ * $step + 1) for 1 .. $factor_count;
                next if $even_min_log > $log_bound + 1e-9;
            }

            my @found;
            my $log_prod = 0;
            Rmpz_set_ui($prod, 1);

            my $limit = next_prime_limit($factor_count, $step, 0);
            my $cand  = $step + 1;

            my ($lam_primes, @sub_orders);
            my $resolved_early = 0;

            my $try_cofactor = sub () {
                $lam_primes //= [map { $_->[0] } factor_exp($lambda)];
                return resolve_by_cofactor($lambda, $lam_primes, \@found, $limit > $MAX_NATIVE_STEP);
            };

            if ($cand <= $limit
                and ((($limit - $cand) / $step > $MAX_SCAN_STEPS) or $limit > $MAX_NATIVE_STEP)) {
                $resolved_early = 1;
                next LAMBDA if $try_cofactor->();
            }

            while ($cand <= $limit) {

                if (powmod(2, $lambda, $cand) == 1) {

                    $lam_primes //= [map { $_->[0] } factor_exp($lambda)];
                    @sub_orders = map { divint($lambda, $_) } @$lam_primes if !@sub_orders;

                    my $exact_order = 1;
                    foreach my $sub_ord (@sub_orders) {
                        if (powmod(2, $sub_ord, $cand) == 1) {
                            $exact_order = 0;
                            last;
                        }
                    }

                    if ($exact_order and is_prime($cand)) {

                        push @found, $cand;
                        Rmpz_set_str($cand_z, "$cand", 10);
                        Rmpz_mul($prod, $prod, $cand_z);
                        $log_prod += log($cand);

                        if (@found == $factor_count) {
                            record_candidate($prod);
                            next LAMBDA;
                        }

                        $limit = next_prime_limit($factor_count - @found, $step, $log_prod);

                        if (!$resolved_early
                            and ((($limit - $cand) / $step > $MAX_SCAN_STEPS) or $limit > $MAX_NATIVE_STEP)) {
                            $resolved_early = 1;
                            next LAMBDA if $try_cofactor->();
                        }
                    }
                }

                $cand += $step;
            }
        }
    }

    Rmpz_set_ui($tmp1, 1);
    Rmpz_mul_2exp($tmp1, $tmp1, 4 * $factor_count + 4);
    set_bound($tmp1);

    while (1) {
        search_pass();
        return Rmpz_init_set($best) if $has_best;
        Rmpz_mul_2exp($tmp1, $bound, $factor_count);
        set_bound($tmp1);
    }
}

foreach my $n (2 .. 7) {
    say "a($n) = ", fermat_overpsp_base2_smallest($n);
}
