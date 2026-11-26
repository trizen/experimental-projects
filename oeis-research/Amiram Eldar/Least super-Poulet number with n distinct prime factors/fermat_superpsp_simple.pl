#!/usr/bin/env perl

# Daniel Suteu (with assistance from Claude AI and Google Gemini)
# Date: 26 November 2026
# https://oeis.org/A328665

# Smallest Fermat superpseudoprime to base 2 (super-Poulet number) with exactly n distinct
# prime factors (OEIS A050217): the least Poulet number n with omega(n) = k, all of whose
# divisors d satisfy d | 2^d - 2.
#
# Requires Math::GMPz, Math::Prime::Util and Math::Prime::Util::GMP.
#
# How the search works
# --------------------
# Let z_p = ord_p(2).  For a squarefree n = p_1 * ... * p_k a divisor d' = prod_{p in S} p
# satisfies d' | 2^d' - 2 iff z_p | d'-1 for every p in S, and since p == 1 (mod z_p) this is
# the same as z_p | (d'/p) - 1.  Taking S = {p, q} shows that
#
#     n is super-Poulet   <=>   z_p | q - 1  for all primes p != q dividing n,
#
# and then every divisor is automatically fine (a product of numbers == 1 mod z_p is
# == 1 mod z_p).  With d = lcm(z_p) this says that  p == 1 (mod d)  and  z_p | d  for all
# the primes of n, i.e. all the primes of n lie in
#
#     A_d = { p prime : p == 1 (mod d)  and  p | 2^d - 1 },
#
# and, conversely, any k distinct primes of A_d give a super-Poulet number (every divisor
# is == 1 mod d, and the order of 2 divides d).  So the squarefree terms are exactly the
# products of k primes of some A_d (this is the family of the generation algorithm).
#
# The least term is squarefree: if p^2 | n then n/p is again a super-Poulet number (its
# divisors are divisors of n) with the same number of distinct prime factors, and it is
# smaller.  Hence
#
#     a(k) = min over d of (the product of the k smallest primes of A_d),
#
# and the search runs over d (not over a tree of primes):
#
#   * the primes of A_d are p = j*d + 1 (j even when d is odd); they are tested in increasing
#     order with 2^d == 1 (mod p) and a primality test (only for the rare hits);
#   * the shared upper bound B is lowered to (n - 1) whenever a smaller term is found;
#   * d is limited by the product of the k smallest allowed values j*d + 1 <= B;
#   * the next prime is limited by  q*(q+s)*(q+2s)*... <= B / (product found so far)  (s is
#     the progression step); the last prime may be as large as B / (product of the other
#     k-1), which is the only place where the scan can become long;
#   * when the scan would be long, 2^d - 1 is factored with Math::Prime::Util::GMP instead
#     (the found primes are divided out; the primes q == 1 (mod d) of the cofactor are the
#     remaining elements of A_d);
#   * doubling bound B: a pass with the bound B finds the smallest term <= B (if any).

use v5.36;
use strict;
use warnings;

use Math::GMPz             qw(:mpz);
use Math::Prime::Util      qw(powmod is_prime);
use Math::Prime::Util::GMP ();

sub fermat_superpsp_base2_smallest ($k, %opt) {
    die "k must be an integer >= 2\n" if !defined($k) || "$k" !~ /\A\d+\z/ || $k < 2;
    $k = 0 + $k;

    my $max_scan_steps  = $opt{scan_steps}  // 5000;
    my $max_factor_bits = $opt{factor_bits} // 128;
    my $growth_shift    = 0 + ($opt{growth} // $k);

    die "scan_steps must be a non-negative integer\n"  if $max_scan_steps  !~ /\A\d+\z/;
    die "factor_bits must be a non-negative integer\n" if $max_factor_bits !~ /\A\d+\z/;

    my $NATIVE_MAX = 1.7e19;
    my $LOG10      = log(10);

    my $bound     = Rmpz_init();
    my $log_bound = 0;
    my $best      = Rmpz_init();
    my $has_best  = 0;

    my ($prod, $cofactor, $tmp_a, $tmp_b) = map { Rmpz_init() } 1 .. 4;
    my ($prime_z, $mult_z) = (Rmpz_init(), Rmpz_init());

    my sub mpz_log ($z) {
        my $digits = Rmpz_get_str($z, 10);
        my $len    = length($digits);
        return log($digits) if $len <= 15;
        return log(substr($digits, 0, 15)) + ($len - 15) * $LOG10;
    }

    my sub set_bound ($z) {
        Rmpz_set($bound, $z);
        $log_bound = mpz_log($bound);
    }

    my sub record_candidate ($n) {
        return if Rmpz_cmp($n, $bound) > 0;
        Rmpz_set($best, $n);
        $has_best = 1;
        Rmpz_sub_ui($tmp_a, $n, 1);
        set_bound($tmp_a);
    }

    my sub max_next_prime ($rem, $step, $log_prod) {
        my $target = $log_bound - $log_prod + 1e-9;
        return 1.0              if $target <= -700;
        return exp($target) + 1 if $rem == 1;

        my $lo = 1.0;
        my $hi = exp($target / $rem) + 1;

        for (1 .. 56) {
            my $mid = 0.5 * ($lo + $hi);
            last if $mid == $lo || $mid == $hi;

            my $sum = log($mid);
            my $cur = $mid;
            for (1 .. $rem - 1) {
                $cur += $step;
                $sum += log($cur);
            }

            if   ($sum <= $target) { $lo = $mid }
            else                   { $hi = $mid }
        }

        return $hi + 1;
    }

    my sub resolve_by_factoring ($mult, $found_primes, $force) {
        return 0 if !$force && $mult > $max_factor_bits;

        Rmpz_set_ui($cofactor, 1);
        Rmpz_mul_2exp($cofactor, $cofactor, $mult);
        Rmpz_sub_ui($cofactor, $cofactor, 1);

        for my $p (@$found_primes) {
            Rmpz_set_str($prime_z, "$p", 10);
            while (Rmpz_divisible_p($cofactor, $prime_z)) {
                Rmpz_divexact($cofactor, $cofactor, $prime_z);
            }
        }

        return 1 if Rmpz_cmp_ui($cofactor, 1) == 0;

        my $needed = $k - scalar(@$found_primes);
        my (%seen, @valid_q);

        Rmpz_set_str($mult_z, "$mult", 10);
        for my $factor (Math::Prime::Util::GMP::factor(Rmpz_get_str($cofactor, 10))) {
            next if $seen{$factor}++;
            Rmpz_set_str($tmp_a, $factor, 10);
            Rmpz_sub_ui($tmp_a, $tmp_a, 1);
            next if !Rmpz_divisible_p($tmp_a, $mult_z);
            push @valid_q, Rmpz_init_set_str($factor, 10);
        }

        return 1 if @valid_q < $needed;

        @valid_q = sort { Rmpz_cmp($a, $b) } @valid_q;

        Rmpz_set($tmp_b, $prod);
        Rmpz_mul($tmp_b, $tmp_b, $valid_q[$_]) for 0 .. $needed - 1;
        record_candidate($tmp_b);

        return 1;
    }

    my sub search_pass () {
      MULT: for (my $mult = 2 ; ; ++$mult) {
            my $min_log = 0;
            $min_log += log($_ * $mult + 1) for 1 .. $k;
            last if $min_log > $log_bound + 1e-9;

            my $step = ($mult & 1) ? 2 * $mult : $mult;

            if ($step != $mult) {
                my $step_min_log = 0;
                $step_min_log += log($_ * $step + 1) for 1 .. $k;
                next if $step_min_log > $log_bound + 1e-9;
            }

            my @found_primes;
            my $log_prod = 0;
            Rmpz_set_ui($prod, 1);

            my $q_hi     = max_next_prime($k, $step, 0);
            my $q        = $step + 1;
            my $factored = 0;

            if ($q <= $q_hi && ((($q_hi - $q) / $step > $max_scan_steps) || $q_hi > $NATIVE_MAX)) {
                $factored = 1;
                next MULT if resolve_by_factoring($mult, \@found_primes, $q_hi > $NATIVE_MAX);
            }

            for (; $q <= $q_hi ; $q += $step) {
                if (powmod(2, $mult, $q) == 1 && is_prime($q)) {
                    push @found_primes, $q;
                    Rmpz_set_str($prime_z, "$q", 10);
                    Rmpz_mul($prod, $prod, $prime_z);
                    $log_prod += log($q);

                    if (@found_primes == $k) {
                        record_candidate($prod);
                        next MULT;
                    }

                    $q_hi = max_next_prime($k - @found_primes, $step, $log_prod);

                    if (!$factored && ((($q_hi - $q) / $step > $max_scan_steps) || $q_hi > $NATIVE_MAX)) {
                        $factored = 1;
                        next MULT if resolve_by_factoring($mult, \@found_primes, $q_hi > $NATIVE_MAX);
                    }
                }
            }
        }
    }

    Rmpz_set_ui($tmp_a, 1);
    Rmpz_mul_2exp($tmp_a, $tmp_a, 4 * $k + 4);
    set_bound($tmp_a);

    while (1) {
        search_pass();
        return Rmpz_init_set($best) if $has_best;
        Rmpz_mul_2exp($tmp_a, $bound, $growth_shift);
        set_bound($tmp_a);
    }
}

for my $n (2 .. 10) {
    say "a($n) = ", fermat_superpsp_base2_smallest($n);
}
