#!/usr/bin/env perl

# Daniel Suteu (with assistance from Claude AI and Google Geimini)
# Optimized translation of my older PARI/GP program.
# Date: 27 November 2026
# https://oeis.org/A270973

# Smallest even Fermat pseudoprime to base 2 with exactly n distinct prime factors
# (OEIS A006935):  the least even composite m with omega(m) = n and 2^m == 2 (mod m).
#
# Requires Math::Prime::Util >= 0.74 and Math::GMPz.
#
# How the search works
# --------------------
# An even n with 2^n == 2 (mod n) is n = 2*m with m odd (4 | n is impossible: 2^n == 0 mod 4)
# and 2^(n-1) == 1 (mod p^e) for every p^e || m, i.e. ord_{p^e}(2) | n-1.  Since n-1 is odd:
#
#   * every ord_p(2) = z_p must be odd, so only the primes with an odd order of 2 (about 29%
#     of the primes) can occur; the other ones are never put in the prime table;
#   * with L = lcm(z_p) (odd), n == 1 (mod L);
#   * the odd prime powers p^e (e >= 2) need ord_{p^e}(2) = z_p, i.e. p is a Wieferich prime
#     (3511 is the only known one with an odd order; 1093 has the even order 364).
#
# The search is the base-2 Fermat search started from m = 2 (the prime 2 counts as one of the
# k prime factors).  The odd primes p_1 < ... < p_(k-2) are chosen by depth-first search;
# with m = 2*p_1*...*p_j and L = lcm(z_p_1, ..., z_p_j), every completion n = m*q needs
# n == 1 (mod L).  Shortcuts:
#
#   * forced completion: q must be one of the (odd) numbers  first + t*(2L)  in [q_min, q_max],
#     where first = m^(-1) mod L; if there are few of them they are factored directly and
#     every prime s of q is tested with 2^(n-1) == 1 (mod s);
#   * the last prime p: since z_p | p-1, the condition z_p | n-1 is equivalent to
#     z_p | m-1, i.e. 2^(m-1) == 1 (mod p) (m-1 is odd, so the order of p is automatically odd);
#     together with p == m^(-1) (mod L) this is a short progression that is walked;
#   * the last two levels (the loop over p_(k-2) and the terminal prime) are inlined;
#   * the cofactor lower bound uses the consecutive primes of the (odd-order) prime list.
#
# Prime powers.  Each combination "w^e | n" (w a Wieferich prime with an odd order) is a
# separate run that starts from the given multiple m_0 = 2 * prod w^e, with the primes dividing
# m_0 or lcm(z_w) removed from the list.  Every prime that can occur is checked while the
# prime table is built, so the code stays correct if another Wieferich prime were ever found.
#
# Interval search.  The intervals [lower, upper] are contiguous and doubling, so the first
# interval containing a solution contains the global minimum.  Inside an interval the upper
# bound is lowered to (best - 1) every time something is found, which prunes the rest of
# the search (including the loop bounds of the nodes that are already on the stack).
#
# Two phases.  The terms are made of small primes (all but the largest prime are tiny compared
# to the sieve bound that a complete search needs), so
#   1. a heuristic search limits the non-terminal primes to <= cap: it is very fast and gives a
#      valid upper bound U (the terminal prime is never limited);
#   2. one exact pass over [smallest possible n, U - 1] either finds a smaller term or proves
#      that U is the least one.
# With --upper=N the first phase is skipped and N is used as U.
#
# Facts used:
#   * gcd(m, z_p) = 1 is necessary (a prime of m would divide both n and n-1);
#   * L divides n-1, hence L < B;
#   * there is no even term with two prime factors (n = 2p: 2^n == 2 (mod p) would give
#     2^2 == 2).

use v5.36;
no warnings 'recursion';

use Math::GMPz        qw(:mpz);
use Math::Prime::Util qw(:all);

use constant {
              FORCE_MAX_BITS   => 64,
              FORCE_MIN_COUNT  => 16,
              FORCE_COST_RATIO => 0.75,
              HEURISTIC_CAP    => 8192,
             };

sub smallest_even_fermat_psp ($num_factors) {
    die "Number of prime factors must be an integer >= 3\n"
      if (!defined($num_factors) || $num_factors < 3);
    $num_factors += 0;

    my $GMP_ONE  = Rmpz_init_set_ui(1);
    my $GMP_TWO  = Rmpz_init_set_ui(2);
    my $GMP_NULL = $Math::GMPz::NULL;

    my $upper_bound   = Rmpz_init();    # inclusive upper bound; lowered whenever a solution is found
    my $best_n        = Rmpz_init();
    my $found_best    = 0;
    my $bound_version = 0;

    # Odd primes with an odd order of 2, their orders ord_p(2), and Wieferich primes among them
    my (@odd_order_primes, @odd_orders, @wieferich_primes);
    my $sieved_up_to = 2;

    my ($prime_cap, $was_truncated) = (0, 0);

    # Shared scratch GMP integers (never live across recursive calls)
    my ($tmp1, $tmp2, $tmp3, $first_q, $cand_q, $cand_n_minus_1, $cand_n, $mod_res) =
      map { Rmpz_init() } 1 .. 8;
    my ($tail_lcm, $tail_m, $tail_q_max, $tail_q_min, $tail_m_minus_1, $tail_q, $tail_n, $step) =
      map { Rmpz_init() } 1 .. 8;

    my sub record_solution ($n) {
        Rmpz_set($best_n, $n);
        Rmpz_sub_ui($upper_bound, $n, 1);
        $found_best = 1;
        ++$bound_version;
    }

    my sub is_gmp_prime ($z) {
        return is_prime(Rmpz_fits_ulong_p($z) ? Rmpz_get_ui($z) : Rmpz_get_str($z, 10));
    }

    # Largest exponent e >= 1 such that 2^z == 1 (mod p^e), where z = ord_p(2)
    my sub wieferich_exponent ($p, $z) {

        if ($p < 4294967296) {    # p^2 fits in 64 bits
            return 1 if powmod(2, $z, $p * $p) != 1;
        }

        my $pe  = Rmpz_init_set_str("$p", 10);
        my $pz  = Rmpz_init_set_str("$p", 10);
        my $zz  = Rmpz_init_set_str("$z", 10);
        my $rem = Rmpz_init();
        my $exp = 1;

        while (1) {
            Rmpz_mul($pe, $pe, $pz);
            Rmpz_powm($rem, $GMP_TWO, $zz, $pe);
            last if Rmpz_cmp_ui($rem, 1) != 0;
            ++$exp;
        }

        return $exp;
    }

    my sub extend_prime_table ($limit) {
        return if $limit <= $sieved_up_to;

        for my $p (@{primes($sieved_up_to + 1, $limit)}) {

            # ord_p(2) must be odd since it divides n - 1
            next if powmod(2, ($p - 1) >> valuation($p - 1, 2), $p) != 1;

            my $z = znorder(2, $p);
            push @odd_order_primes, $p;
            push @odd_orders,       $z;

            my $exp = wieferich_exponent($p, $z);
            push @wieferich_primes, [$p, $exp, $z] if $exp > 1;
        }

        $sieved_up_to = $limit;
    }

    my sub smallest_coprime_primes ($count, $base_m, $base_lcm) {
        my @primes;
        my $p = 2;

        while (@primes < $count) {
            $p = next_prime($p);
            next if Rmpz_divisible_ui_p($base_m, $p) || Rmpz_divisible_ui_p($base_lcm, $p);
            next if powmod(2, ($p - 1) >> valuation($p - 1, 2), $p) != 1;
            push @primes, $p;
        }

        return @primes;
    }

    my sub compute_sieve_limit ($min_prefix, $remaining_primes) {
        my $limit = Rmpz_init_set_ui(3);

        for my $depth (0 .. $remaining_primes - 2) {
            Rmpz_fdiv_q($tmp1, $upper_bound, $min_prefix->[$depth]);
            Rmpz_root($tmp1, $tmp1, $remaining_primes - $depth);
            Rmpz_set($limit, $tmp1) if Rmpz_cmp($tmp1, $limit) > 0;
        }

        die "Search range too large\n" if !Rmpz_fits_ulong_p($limit);

        my $sieve_max = Rmpz_get_ui($limit);
        if ($prime_cap > 0 && $sieve_max > $prime_cap) {
            $sieve_max     = $prime_cap;
            $was_truncated = 1;
        }

        extend_prime_table($sieve_max);
        return $sieve_max;
    }

    # Search n = base_m * q in [min_n_in, upper_bound] where q is a squarefree product
    # of (num_factors - 1 - wieferich_count) odd primes coprime to base_m.
    my sub search_combo ($min_n_in, $base_m, $base_lcm, $wieferich_count) {
        my $remaining_primes = $num_factors - 1 - $wieferich_count;
        return if $remaining_primes < 2;
        return if Rmpz_cmp($base_m, $upper_bound) > 0;

        Rmpz_gcd($tmp1, $base_m, $base_lcm);
        return if Rmpz_cmp_ui($tmp1, 1) != 0;

        my $has_wieferich = $wieferich_count > 0 ? 1 : 0;

        my @min_prefix = (Rmpz_init_set($base_m));
        my @min_primes = smallest_coprime_primes($remaining_primes, $base_m, $base_lcm);

        for my $j (1 .. $remaining_primes) {
            my $prod = Rmpz_init();
            Rmpz_mul_ui($prod, $min_prefix[$j - 1], $min_primes[$j - 1]);
            return if Rmpz_cmp($prod, $upper_bound) > 0;
            push @min_prefix, $prod;
        }

        my $min_n         = Rmpz_init_set($min_n_in);
        my $enforce_min_n = Rmpz_cmp($min_n, $min_prefix[$remaining_primes]) > 0 ? 1 : 0;
        Rmpz_set($min_n, $min_prefix[$remaining_primes]) if !$enforce_min_n;

        my $sieve_max = compute_sieve_limit(\@min_prefix, $remaining_primes);

        my (@primes, @orders);
        for my $i (0 .. $#odd_order_primes) {
            my $p = $odd_order_primes[$i];
            last if $p > $sieve_max;
            next if $has_wieferich && (Rmpz_divisible_ui_p($base_m, $p) || Rmpz_divisible_ui_p($base_lcm, $p));
            push @primes, $p;
            push @orders, $odd_orders[$i];
        }
        push @primes, $sieve_max + 1;    # sentinel
        push @orders, 1;

        my @depth_m     = map { Rmpz_init() } 0 .. $remaining_primes;
        my @depth_lcm   = map { Rmpz_init() } 0 .. $remaining_primes;
        my @depth_qmax  = map { Rmpz_init() } 0 .. $remaining_primes;
        my @depth_qmin  = map { Rmpz_init() } 0 .. $remaining_primes;
        my @depth_min_q = map { Rmpz_init() } 0 .. $remaining_primes;

        Rmpz_set($depth_m[0],   $base_m);
        Rmpz_set($depth_lcm[0], $base_lcm);

        sub ($depth, $start_idx, $primes_left) {
            my $m     = $depth_m[$depth];
            my $lcm   = $depth_lcm[$depth];
            my $q_max = $depth_qmax[$depth];
            my $q_min = $depth_qmin[$depth];
            my $min_q = $depth_min_q[$depth];

            Rmpz_fdiv_q($q_max, $upper_bound, $m);

            my $lo_prime = $primes[$start_idx];
            Rmpz_root($tmp1, $q_max, $primes_left);
            my $hi_prime = Rmpz_get_ui($tmp1);
            $hi_prime = $sieve_max if $hi_prime > $sieve_max;
            return if $lo_prime > $hi_prime;

            Rmpz_set_ui($q_min, $lo_prime);
            Rmpz_mul_ui($q_min, $q_min, $primes[$start_idx + $_ > $#primes ? $#primes : $start_idx + $_])
              for 1 .. $primes_left - 1;
            return if Rmpz_cmp($q_min, $q_max) > 0;

            if ($enforce_min_n) {
                Rmpz_cdiv_q($min_q, $min_n, $m);
                if (Rmpz_cmp($min_q, $q_min) > 0) {
                    Rmpz_set($q_min, $min_q);
                    return if Rmpz_cmp($q_min, $q_max) > 0;
                }
            }

            # Forced completion: walk odd arithmetic progression q == m^(-1) (mod lcm) directly
            # when few candidates remain and q_max fits within FORCE_MAX_BITS.
            if (Rmpz_cmp_ui($lcm, 1) > 0) {
                Rmpz_invert($first_q, $m, $lcm) or die "Internal error: modular inverse does not exist\n";

                if (Rmpz_cmp($first_q, $q_min) < 0) {
                    Rmpz_sub($tmp1, $q_min, $first_q);
                    Rmpz_cdiv_q($tmp1, $tmp1, $lcm);
                    Rmpz_addmul($first_q, $tmp1, $lcm);
                }

                Rmpz_add($first_q, $first_q, $lcm) if !Rmpz_tstbit($first_q, 0);
                Rmpz_mul_2exp($step, $lcm, 1);

                return if Rmpz_cmp($first_q, $q_max) > 0;

                Rmpz_sub($tmp1, $q_max, $first_q);
                Rmpz_fdiv_q($tmp1, $tmp1, $step);

                if (Rmpz_fits_ulong_p($tmp1) && Rmpz_sizeinbase($q_max, 2) <= FORCE_MAX_BITS) {
                    my $num_candidates = Rmpz_get_ui($tmp1) + 1;

                    my $est_primes =
                      $hi_prime > $lo_prime
                      ? ($hi_prime / log($hi_prime) - $lo_prime / log($lo_prime))
                      : 1;
                    $est_primes = 1 if $est_primes < 1;

                    my $max_candidates = FORCE_COST_RATIO * $est_primes;
                    $max_candidates = FORCE_MIN_COUNT if $max_candidates < FORCE_MIN_COUNT;

                    if ($num_candidates <= $max_candidates) {
                        Rmpz_set($cand_q, $first_q);

                        while (Rmpz_cmp($cand_q, $q_max) <= 0) {
                            my $q_val =
                                Rmpz_fits_ulong_p($cand_q)
                              ? Rmpz_get_ui($cand_q)
                              : Rmpz_get_str($cand_q, 10);

                            if (is_rough($q_val, $lo_prime) && is_almost_prime($primes_left, $q_val)) {
                                my @factors = factor_exp($q_val);
                                if (@factors == $primes_left && $factors[0][0] >= $lo_prime) {
                                    my $is_valid = 1;
                                    Rmpz_mul($cand_n, $m, $cand_q);
                                    Rmpz_sub_ui($cand_n_minus_1, $cand_n, 1);

                                    for my $factor_pair (@factors) {
                                        my ($prime_factor, $exp) = @$factor_pair;
                                        if ($exp != 1) {
                                            $is_valid = 0;
                                            last;
                                        }

                                        Rmpz_set_str($tmp3, "$prime_factor", 10);

                                        if ($has_wieferich && Rmpz_divisible_p($base_m, $tmp3)) {
                                            $is_valid = 0;
                                            last;
                                        }
                                        Rmpz_powm($mod_res, $GMP_TWO, $cand_n_minus_1, $tmp3);
                                        if (Rmpz_cmp_ui($mod_res, 1) != 0) {
                                            $is_valid = 0;
                                            last;
                                        }
                                    }

                                    if ($is_valid) {
                                        record_solution($cand_n);
                                        return;
                                    }
                                }
                            }

                            Rmpz_add($cand_q, $cand_q, $step);
                        }
                        return;
                    }
                }
            }

            # Standard DFS branch
            if ($primes_left > 2) {
                my $child_m      = $depth_m[$depth + 1];
                my $child_lcm    = $depth_lcm[$depth + 1];
                my $prev_version = $bound_version;

                for (my $i = $start_idx ; ; ++$i) {
                    my $p = $primes[$i];
                    last if $p > $hi_prime;

                    my $z = $orders[$i];
                    next if Rmpz_gcd_ui($GMP_NULL, $m, $z) != 1;

                    Rmpz_lcm_ui($child_lcm, $lcm, $z);
                    next if Rmpz_cmp($child_lcm, $upper_bound) >= 0;

                    Rmpz_mul_ui($child_m, $m, $p);
                    __SUB__->($depth + 1, $i + 1, $primes_left - 1);

                    if ($prev_version != $bound_version) {
                        $prev_version = $bound_version;
                        Rmpz_fdiv_q($q_max, $upper_bound, $m);
                        Rmpz_root($tmp1, $q_max, $primes_left);
                        $hi_prime = Rmpz_get_ui($tmp1);
                        $hi_prime = $sieve_max if $hi_prime > $sieve_max;
                    }
                }
                return;
            }

            # Inlined tail for the final two primes (p and terminal prime q)
            for (my $i = $start_idx ; ; ++$i) {
                my $p = $primes[$i];
                last if $p > $hi_prime;

                Rmpz_lcm_ui($tail_lcm, $lcm, $orders[$i]);
                Rmpz_mul_ui($tail_m, $m, $p);

                Rmpz_invert($tail_q, $tail_m, $tail_lcm) or next;

                Rmpz_fdiv_q_ui($tail_q_max, $q_max, $p);
                next if Rmpz_cmp($tail_q, $tail_q_max) > 0;

                if (Rmpz_tstbit($tail_lcm, 0)) {
                    Rmpz_add($tail_q, $tail_q, $tail_lcm) if !Rmpz_tstbit($tail_q, 0);
                    Rmpz_mul_2exp($step, $tail_lcm, 1);
                }
                else {
                    Rmpz_set($step, $tail_lcm);
                }

                Rmpz_set_ui($tail_q_min, $p + 2);
                if ($enforce_min_n) {
                    Rmpz_cdiv_q_ui($tmp2, $min_q, $p);
                    Rmpz_set($tail_q_min, $tmp2) if Rmpz_cmp($tmp2, $tail_q_min) > 0;
                }

                if (Rmpz_cmp($tail_q, $tail_q_min) < 0) {
                    Rmpz_sub($tmp2, $tail_q_min, $tail_q);
                    Rmpz_cdiv_q($tmp2, $tmp2, $step);
                    Rmpz_addmul($tail_q, $tmp2, $step);
                }
                next if Rmpz_cmp($tail_q, $tail_q_max) > 0;

                Rmpz_sub_ui($tail_m_minus_1, $tail_m, 1);
                my $found_tail = 0;

                if (   Rmpz_fits_ulong_p($tail_m_minus_1)
                    && Rmpz_fits_ulong_p($tail_q_max)
                    && Rmpz_fits_ulong_p($step)) {

                    my ($q_u, $q_max_u, $step_u, $exp_u) = (
                        Rmpz_get_ui($tail_q), Rmpz_get_ui($tail_q_max),
                        Rmpz_get_ui($step), Rmpz_get_ui($tail_m_minus_1),
                    );

                    for (; $q_u <= $q_max_u ; $q_u += $step_u) {
                        if (powmod(2, $exp_u, $q_u) == 1 && is_prime($q_u)) {
                            next if $has_wieferich && Rmpz_divisible_ui_p($base_m, $q_u);
                            Rmpz_mul_ui($tail_n, $tail_m, $q_u);
                            $found_tail = 1;
                            last;
                        }
                    }
                }
                else {
                    while (Rmpz_cmp($tail_q, $tail_q_max) <= 0) {
                        Rmpz_powm($mod_res, $GMP_TWO, $tail_m_minus_1, $tail_q);
                        if (   Rmpz_cmp_ui($mod_res, 1) == 0
                            && !($has_wieferich && Rmpz_divisible_p($base_m, $tail_q))
                            && is_gmp_prime($tail_q)) {
                            Rmpz_mul($tail_n, $tail_m, $tail_q);
                            $found_tail = 1;
                            last;
                        }
                        Rmpz_add($tail_q, $tail_q, $step);
                    }
                }

                if ($found_tail) {
                    record_solution($tail_n);

                    Rmpz_fdiv_q($q_max, $upper_bound, $m);
                    Rmpz_root($tmp1, $q_max, 2);
                    $hi_prime = Rmpz_get_ui($tmp1);
                    $hi_prime = $sieve_max if $hi_prime > $sieve_max;
                }
            }
        }->(0, 0, $remaining_primes);
    }

    my sub search_interval ($interval_min) {

        # Squarefree odd part (also populates @wieferich_primes up to the sieve limit)
        search_combo($interval_min, $GMP_TWO, $GMP_ONE, 0);

        # Combinations divisible by Wieferich prime powers w^e (e >= 2)
        my @wieferich_combos = ([$GMP_TWO, $GMP_ONE, 0]);
        for my $w (@wieferich_primes) {
            my ($p, $max_exp, $z) = @$w;
            my @next_combos;

            for my $combo (@wieferich_combos) {
                my ($m0, $l0, $r) = @$combo;
                for my $exp (2 .. $max_exp) {
                    my $next_m = Rmpz_init_set_ui($p);
                    Rmpz_pow_ui($next_m, $next_m, $exp);
                    Rmpz_mul($next_m, $next_m, $m0);

                    my $next_lcm = Rmpz_init_set_ui($z);
                    Rmpz_lcm($next_lcm, $next_lcm, $l0);

                    push @next_combos, [$next_m, $next_lcm, $r + 1];
                }
            }
            push @wieferich_combos, @next_combos;
        }

        shift @wieferich_combos;    # squarefree case already searched
        search_combo($interval_min, @$_) for @wieferich_combos;
    }

    my sub run_interval ($lo, $hi) {
        Rmpz_set($upper_bound, $hi);
        $found_best    = 0;
        $was_truncated = 0;
        search_interval($lo);
        return $found_best;
    }

    my $global_min_n = Rmpz_init_set_ui(2);
    Rmpz_mul_ui($global_min_n, $global_min_n, $_)
      for smallest_coprime_primes($num_factors - 1, $GMP_TWO, $GMP_ONE);

    my $interval_lo = Rmpz_init_set($global_min_n);
    my $interval_hi = Rmpz_init();
    Rmpz_mul_2exp($interval_hi, $interval_lo, 1);

    # Phase 1 (heuristic): doubling intervals with non-terminal primes capped at HEURISTIC_CAP
    $prime_cap = HEURISTIC_CAP;
    my $ever_truncated = 0;

    while (1) {
        my $found = run_interval($interval_lo, $interval_hi);
        $ever_truncated ||= $was_truncated;

        if ($found) {
            return Rmpz_init_set($best_n) if !$ever_truncated;
            last;
        }

        Rmpz_add_ui($interval_lo, $interval_hi, 1);
        Rmpz_mul_2exp($interval_hi, $interval_hi, 1);
    }

    # Phase 2 (exact): uncapped pass below the heuristic upper bound to verify minimality
    my $heuristic_best    = Rmpz_init_set($best_n);
    my $exact_upper_bound = Rmpz_init();
    Rmpz_sub_ui($exact_upper_bound, $heuristic_best, 1);

    $prime_cap = 0;
    return run_interval($global_min_n, $exact_upper_bound)
      ? Rmpz_init_set($best_n)
      : $heuristic_best;
}

for my $n (3 .. 20) {
    say "a($n) = ", smallest_even_fermat_psp($n);
}
