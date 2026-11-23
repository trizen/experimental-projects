#!/usr/bin/env perl

# Daniel Suteu (23 November 2026)
# https://oeis.org/A253598

use v5.36;
use strict;
use warnings;

use Math::GMPz qw(:mpz);
use Math::Prime::Util 0.74 qw(:all);

my $FORCE_BITS  = 64;
my $FORCE_COUNT = 16;
my $FORCE_RATIO = 0.75;
my $STEP_DIV    = 64;

sub z_from_dec ($value) {
    my $z = Rmpz_init();
    Rmpz_set_str($z, "$value", 10);
    return $z;
}

sub z_string ($z) {
    return Rmpz_get_str($z, 10);
}

sub z_is_prime ($z) {
    return is_prime(Rmpz_fits_ulong_p($z) ? Rmpz_get_ui($z) : z_string($z));
}

sub generate_lucas_carmichael_multiples ($min_n, $max_n, $k, $base_m, $callback) {

    die "k must be an integer >= 3\n" if $k < 3;

    $min_n  = z_from_dec($min_n);
    $max_n  = z_from_dec($max_n);
    $base_m = z_from_dec($base_m);

    return if Rmpz_cmp($min_n,  $max_n) > 0;
    return if Rmpz_cmp($base_m, $max_n) > 0;

    # Base multiple must be odd and squarefree.
    return if Rmpz_divisible_ui_p($base_m, 2);

    my $has_base_factors = (Rmpz_cmp_ui($base_m, 1) > 0) ? 1 : 0;

    my @base_factors = $has_base_factors ? factor_exp($base_m) : ();
    foreach my $pe (@base_factors) {
        return if $pe->[1] != 1;
    }

    my $base_factor_count = scalar(@base_factors);
    return if $base_factor_count > $k;
    my $missing_primes = $k - $base_factor_count;

    # base_L = lcm(p + 1 : p | base_m); base_m must be coprime to base_L.
    my ($tmp, $t1, $t2, $t3, $t4) = map { Rmpz_init() } 1 .. 5;
    my $base_L = Rmpz_init_set_ui(1);
    foreach my $pe (@base_factors) {
        Rmpz_set_str($tmp, "$pe->[0]", 10);
        Rmpz_add_ui($tmp, $tmp, 1);
        Rmpz_lcm($base_L, $base_L, $tmp);
    }
    Rmpz_gcd($tmp, $base_m, $base_L);
    return if Rmpz_cmp_ui($tmp, 1) != 0;

    # Case 0: no additional primes needed; only base_m itself can qualify.
    if ($missing_primes == 0) {
        Rmpz_add_ui($tmp, $base_m, 1);
        if (Rmpz_cmp($base_m, $min_n) >= 0 && Rmpz_divisible_p($tmp, $base_L)) {
            $callback->(Rmpz_init_set($base_m));
        }
        return;
    }

    # Smallest allowed primes not dividing base_m or base_L.
    my @prefix_prod = (Rmpz_init_set($base_m));
    my $cand_prime  = 2;
    for my $j (1 .. $missing_primes) {
        do {
            $cand_prime = next_prime($cand_prime);
        } while (Rmpz_divisible_ui_p($base_m, $cand_prime) || Rmpz_divisible_ui_p($base_L, $cand_prime));

        my $next_prod = Rmpz_init();
        Rmpz_mul_ui($next_prod, $prefix_prod[$j - 1], $cand_prime);
        return if Rmpz_cmp($next_prod, $max_n) > 0;
        push @prefix_prod, $next_prod;
    }

    my $min_n_matters = (Rmpz_cmp($min_n, $prefix_prod[$missing_primes]) > 0) ? 1 : 0;
    Rmpz_set($min_n, $prefix_prod[$missing_primes]) if !$min_n_matters;

    # Scratch mpz values
    my ($force_start, $cofactor_q, $cand_n_plus_1, $cand_n) = map { Rmpz_init() } 1 .. 4;
    my ($tail_L, $tail_m, $hi_q, $lo_q, $base_m_minus_1, $q_res, $prod_n, $neg_m) = map { Rmpz_init() } 1 .. 8;
    my $gcd_sink = Rmpz_init();

    # Case 1: only one prime q remains; n = base_m * q.
    if ($missing_primes == 1) {

        Rmpz_fdiv_q($hi_q, $max_n, $base_m);
        Rmpz_sub_ui($t2, $base_m, 2);
        Rmpz_set($hi_q, $t2) if Rmpz_cmp($t2, $hi_q) < 0;

        Rmpz_set_ui($lo_q, 3);
        if ($min_n_matters) {
            Rmpz_cdiv_q($t2, $min_n, $base_m);
            Rmpz_set($lo_q, $t2) if Rmpz_cmp($t2, $lo_q) > 0;
        }

        Rmpz_invert($q_res, $base_m, $base_L)
          or die "Internal error: modular inverse does not exist\n";
        Rmpz_sub($q_res, $base_L, $q_res);

        if (Rmpz_cmp($q_res, $lo_q) < 0) {
            Rmpz_sub($t2, $lo_q, $q_res);
            Rmpz_cdiv_q($t2, $t2, $base_L);
            Rmpz_addmul($q_res, $t2, $base_L);
        }

        if (Rmpz_cmp($q_res, $hi_q) <= 0) {

            Rmpz_sub_ui($base_m_minus_1, $base_m, 1);

            Rmpz_sub($t2, $hi_q, $q_res);
            Rmpz_fdiv_q($t2, $t2, $base_L);

            if ($STEP_DIV > 0 && Rmpz_fits_ulong_p($t2) && Rmpz_get_ui($t2) >= $STEP_DIV) {

                Rmpz_add_ui($t3, $hi_q, 1);
                my $div_limit  = Rmpz_fits_ulong_p($t3)             ? Rmpz_get_ui($t3)             : z_string($t3);
                my $div_target = Rmpz_fits_ulong_p($base_m_minus_1) ? Rmpz_get_ui($base_m_minus_1) : z_string($base_m_minus_1);

                foreach my $dv (divisors($div_target, $div_limit)) {
                    Rmpz_set_str($t3, "$dv", 10);
                    Rmpz_sub_ui($t3, $t3, 1);
                    next if Rmpz_cmp($t3, $q_res) < 0;
                    last if Rmpz_cmp($t3, $hi_q) > 0;
                    Rmpz_sub($t4, $t3, $q_res);
                    next if !Rmpz_divisible_p($t4,    $base_L);
                    next if Rmpz_divisible_p($base_m, $t3);
                    if (z_is_prime($t3)) {
                        Rmpz_mul($prod_n, $base_m, $t3);
                        $callback->(Rmpz_init_set($prod_n));
                    }
                }
            }
            else {
                while (Rmpz_cmp($q_res, $hi_q) <= 0) {
                    Rmpz_add_ui($t2, $q_res, 1);
                    if (   Rmpz_divisible_p($base_m_minus_1, $t2)
                        && !Rmpz_divisible_p($base_m, $q_res)
                        && z_is_prime($q_res)) {
                        Rmpz_mul($prod_n, $base_m, $q_res);
                        $callback->(Rmpz_init_set($prod_n));
                    }
                    Rmpz_add($q_res, $q_res, $base_L);
                }
            }
        }

        return;
    }

    # Case >= 2: depth-first search for remaining primes.
    my $sieve_limit = Rmpz_init_set_ui(3);
    for my $depth (0 .. $missing_primes - 2) {
        Rmpz_fdiv_q($tmp, $max_n, $prefix_prod[$depth]);
        Rmpz_root($tmp, $tmp, $missing_primes - $depth);
        Rmpz_set($sieve_limit, $tmp) if Rmpz_cmp($tmp, $sieve_limit) > 0;
    }

    die "Range too large" if !Rmpz_fits_ulong_p($sieve_limit);

    my $sieve_max = Rmpz_get_ui($sieve_limit);

    # Allowed odd primes plus a sentinel larger than any loop bound.
    my @primes = @{primes(3, $sieve_max)};
    if ($has_base_factors) {
        @primes = grep { !Rmpz_divisible_ui_p($base_m, $_) && !Rmpz_divisible_ui_p($base_L, $_) } @primes;
    }
    push @primes, next_prime($sieve_max);

    my @m_stack    = map { Rmpz_init() } 0 .. $missing_primes;
    my @l_stack    = map { Rmpz_init() } 0 .. $missing_primes;
    my @qmax_stack = map { Rmpz_init() } 0 .. $missing_primes;
    my @qmin_stack = map { Rmpz_init() } 0 .. $missing_primes;
    my @aq_stack   = map { Rmpz_init() } 0 .. $missing_primes;

    Rmpz_set($m_stack[0], $base_m);
    Rmpz_set($l_stack[0], $base_L);

    my $max_n_plus_1 = Rmpz_init();
    Rmpz_add_ui($max_n_plus_1, $max_n, 1);

    my $force_enabled = ($FORCE_BITS > 0 && $FORCE_COUNT > 0) ? 1 : 0;

    sub ($depth, $prime_idx, $rem) {

        my $cur_m = $m_stack[$depth];
        my $cur_l = $l_stack[$depth];
        my $qmax  = $qmax_stack[$depth];
        my $qmin  = $qmin_stack[$depth];
        my $aq    = $aq_stack[$depth];

        Rmpz_fdiv_q($qmax, $max_n, $cur_m);

        my $lo = $primes[$prime_idx];

        Rmpz_root($t1, $qmax, $rem);
        my $hi = Rmpz_get_ui($t1);
        return if $lo > $hi;

        Rmpz_set_ui($qmin, $lo);
        Rmpz_mul_ui($qmin, $qmin, $lo + 2 * $_) for 1 .. $rem - 1;
        return if Rmpz_cmp($qmin, $qmax) > 0;

        if ($min_n_matters) {
            Rmpz_cdiv_q($aq, $min_n, $cur_m);
            if (Rmpz_cmp($aq, $qmin) > 0) {
                Rmpz_set($qmin, $aq);
                return if Rmpz_cmp($qmin, $qmax) > 0;
            }
        }

        # Forced completion: factor arithmetic progression q = force_start + t * cur_l directly.
        if ($force_enabled && Rmpz_cmp_ui($cur_l, 1) > 0) {

            Rmpz_invert($force_start, $cur_m, $cur_l)
              or die "Internal error: modular inverse does not exist\n";
            Rmpz_sub($force_start, $cur_l, $force_start);

            if (Rmpz_cmp($force_start, $qmin) < 0) {
                Rmpz_sub($t1, $qmin, $force_start);
                Rmpz_cdiv_q($t1, $t1, $cur_l);
                Rmpz_addmul($force_start, $t1, $cur_l);
            }

            return if Rmpz_cmp($force_start, $qmax) > 0;

            Rmpz_sub($t1, $qmax, $force_start);
            Rmpz_fdiv_q($t1, $t1, $cur_l);

            if (Rmpz_fits_ulong_p($t1) && Rmpz_sizeinbase($qmax, 2) <= $FORCE_BITS) {

                my $cand_count = Rmpz_get_ui($t1) + 1;
                my $threshold  = $FORCE_COUNT;

                if ($FORCE_RATIO > 0) {
                    my $est_primes = $hi > $lo ? ($hi / log($hi) - $lo / log($lo > 2 ? $lo : 3)) : 1;
                    $est_primes = 1 if $est_primes < 1;
                    my $cost_limit = $FORCE_RATIO * $est_primes;
                    $threshold = $cost_limit if $cost_limit > $threshold;
                }

                if ($cand_count <= $threshold) {
                    Rmpz_set($cofactor_q, $force_start);

                    while (Rmpz_cmp($cofactor_q, $qmax) <= 0) {

                        my $q_val =
                            Rmpz_fits_ulong_p($cofactor_q)
                          ? Rmpz_get_ui($cofactor_q)
                          : Rmpz_get_str($cofactor_q, 10);

                        if (is_rough($q_val, $lo) and is_almost_prime($rem, $q_val)) {
                            my @q_factors = factor_exp($q_val);
                            if (@q_factors == $rem && $q_factors[0][0] >= $lo) {
                                my $valid = 1;
                                Rmpz_mul($cand_n, $cur_m, $cofactor_q);
                                Rmpz_add_ui($cand_n_plus_1, $cand_n, 1);

                                for my $pe (@q_factors) {
                                    my ($factor_p, $exp) = @$pe;
                                    if ($exp != 1) { $valid = 0; last }
                                    if (length("$factor_p") < 19) {
                                        if ($has_base_factors && Rmpz_divisible_ui_p($base_m, $factor_p)) {
                                            $valid = 0;
                                            last;
                                        }
                                        if (!Rmpz_divisible_ui_p($cand_n_plus_1, $factor_p + 1)) {
                                            $valid = 0;
                                            last;
                                        }
                                    }
                                    else {
                                        Rmpz_set_str($t3, "$factor_p", 10);
                                        if ($has_base_factors && Rmpz_divisible_p($base_m, $t3)) {
                                            $valid = 0;
                                            last;
                                        }
                                        Rmpz_add_ui($t3, $t3, 1);
                                        if (!Rmpz_divisible_p($cand_n_plus_1, $t3)) {
                                            $valid = 0;
                                            last;
                                        }
                                    }
                                }

                                $callback->(Rmpz_init_set($cand_n)) if $valid;
                            }
                        }

                        Rmpz_add($cofactor_q, $cofactor_q, $cur_l);
                    }

                    return;
                }
            }
        }

        # Ordinary recursion for > 2 remaining primes.
        if ($rem > 2) {
            my $next_m = $m_stack[$depth + 1];
            my $next_l = $l_stack[$depth + 1];

            for (my $idx = $prime_idx ; ; ++$idx) {
                my $p = $primes[$idx];
                last if $p > $hi;
                my $p_plus_1 = $p + 1;

                next if Rmpz_gcd_ui($gcd_sink, $cur_m, $p_plus_1) != 1;

                Rmpz_lcm_ui($next_l, $cur_l, $p_plus_1);
                next if Rmpz_cmp($next_l, $max_n_plus_1) > 0;

                Rmpz_mul_ui($next_m, $cur_m, $p);
                __SUB__->($depth + 1, $idx + 1, $rem - 1);
            }

            return;
        }

        # Inlined tail for the last two primes: p and terminal prime term_p.
        Rmpz_neg($neg_m, $cur_m);

        for (my $idx = $prime_idx ; ; ++$idx) {
            my $p = $primes[$idx];
            last if $p > $hi;
            my $p_plus_1 = $p + 1;

            next if Rmpz_gcd_ui($gcd_sink, $cur_m, $p_plus_1) != 1;

            Rmpz_lcm_ui($tail_L, $cur_l, $p_plus_1);
            Rmpz_mul_ui($tail_m, $neg_m, $p);
            Rmpz_invert($q_res, $tail_m, $tail_L)
              or die "Internal error: terminal modular inverse does not exist\n";

            Rmpz_fdiv_q_ui($hi_q, $qmax, $p);
            next if Rmpz_cmp($q_res, $hi_q) > 0;

            Rmpz_neg($tail_m, $tail_m);
            Rmpz_sub_ui($base_m_minus_1, $tail_m, 1);

            # Single candidate in range.
            Rmpz_add($t2, $q_res, $tail_L);
            if (Rmpz_cmp($t2, $hi_q) > 0) {
                Rmpz_add_ui($t2, $q_res, 1);
                next if !Rmpz_divisible_p($base_m_minus_1, $t2);
                next if Rmpz_cmp_ui($q_res, $p + 1) <= 0;
                Rmpz_mul($prod_n, $tail_m, $q_res);
                next if Rmpz_cmp($prod_n, $min_n) < 0;
                next if ($has_base_factors && Rmpz_divisible_p($base_m, $q_res));
                if (z_is_prime($q_res)) {
                    $callback->(Rmpz_init_set($prod_n));
                }
                next;
            }

            # Multiple candidates in range.
            Rmpz_sub_ui($t2, $tail_m, 2);
            Rmpz_set($hi_q, $t2) if Rmpz_cmp($t2, $hi_q) < 0;

            Rmpz_set_ui($lo_q, $p + 2);
            if ($min_n_matters) {
                Rmpz_cdiv_q_ui($t2, $aq, $p);
                Rmpz_set($lo_q, $t2) if Rmpz_cmp($t2, $lo_q) > 0;
            }

            if (Rmpz_cmp($q_res, $lo_q) < 0) {
                Rmpz_sub($t2, $lo_q, $q_res);
                Rmpz_cdiv_q($t2, $t2, $tail_L);
                Rmpz_addmul($q_res, $t2, $tail_L);
            }
            next if Rmpz_cmp($q_res, $hi_q) > 0;

            Rmpz_sub($t2, $hi_q, $q_res);
            Rmpz_fdiv_q($t2, $t2, $tail_L);

            my $native_ok = Rmpz_fits_ulong_p($base_m_minus_1) && Rmpz_fits_ulong_p($hi_q) && Rmpz_fits_ulong_p($tail_L);

            if (   $native_ok
                && $STEP_DIV > 0
                && Rmpz_fits_ulong_p($t2)
                && Rmpz_get_ui($t2) >= $STEP_DIV) {
                my $hi_u  = Rmpz_get_ui($hi_q);
                my $res_u = Rmpz_get_ui($q_res);
                my $mod_u = Rmpz_get_ui($tail_L);

                foreach my $dv (divisors(Rmpz_get_ui($base_m_minus_1), $hi_u + 1)) {
                    my $term_p = $dv - 1;
                    next if $term_p < $res_u;
                    last if $term_p > $hi_u;
                    if (($term_p - $res_u) % $mod_u == 0 and is_prime($term_p)) {
                        next if ($has_base_factors && Rmpz_divisible_ui_p($base_m, $term_p));
                        Rmpz_mul_ui($prod_n, $tail_m, $term_p);
                        $callback->(Rmpz_init_set($prod_n));
                    }
                }
                next;
            }

            if ($native_ok) {
                my ($cur_q, $max_q, $step_l, $div_m) =
                  (Rmpz_get_ui($q_res), Rmpz_get_ui($hi_q), Rmpz_get_ui($tail_L), Rmpz_get_ui($base_m_minus_1));
                for (; $cur_q <= $max_q ; $cur_q += $step_l) {
                    if ($div_m % ($cur_q + 1) == 0 and is_prime($cur_q)) {
                        next if ($has_base_factors && Rmpz_divisible_ui_p($base_m, $cur_q));
                        Rmpz_mul_ui($prod_n, $tail_m, $cur_q);
                        $callback->(Rmpz_init_set($prod_n));
                    }
                }
                next;
            }

            while (Rmpz_cmp($q_res, $hi_q) <= 0) {
                Rmpz_add_ui($t2, $q_res, 1);
                if (Rmpz_divisible_p($base_m_minus_1, $t2)) {
                    if (!($has_base_factors && Rmpz_divisible_p($base_m, $q_res)) && z_is_prime($q_res)) {
                        Rmpz_mul($prod_n, $tail_m, $q_res);
                        $callback->(Rmpz_init_set($prod_n));
                    }
                }
                Rmpz_add($q_res, $q_res, $tail_L);
            }
        }
      }
      ->(0, 0, $missing_primes);
}

sub find_upperbound ($m) {
    no warnings 'exiting';
    my $upperbound = 0;

    my $min_lim = Math::GMPz->new(10)**18;

    my $lo = Math::GMPz->new(1);
    my $hi = 2 * $lo;

  OUTER: while (1) {
        my $found = 0;

      LOOP: foreach my $k (reverse(3 .. 20)) {
            generate_lucas_carmichael_multiples(
                $lo, $hi, $k, $m,
                sub ($n) {
                    if ($n < $hi) {
                        $hi         = $n;
                        $upperbound = $n;
                        $found      = 1;
                        last OUTER if ($upperbound < $min_lim);
                        next LOOP;
                    }
                }
            );
        }

        last if $found;

        $lo = $hi + 1;
        $hi = 2 * $lo;
    }

    return $upperbound || Math::GMPz->new(10)**100;
}

sub find_term ($m) {

    my $upperbound = find_upperbound($m);

    # Find the smallest term <= upperbound
    foreach my $k (reverse(3 .. 100)) {
        generate_lucas_carmichael_multiples(
            1,
            $upperbound,
            $k, $m,
            sub ($n) {
                if ($n < $upperbound) {
                    $upperbound = $n;
                }
            }
        );
    }

    return $upperbound;
}

my $count = 0;
foreach my $m (1 .. 1e4) {

    $m % 2 == 0 and next;
    is_square_free($m) || next;
    gcd($m, divisor_sum($m)) == 1 or next;

    my $term = find_term($m);
    say ++$count, " ", $term;
}
