#!/usr/bin/env perl

# Daniel Șuteu (with assistance from Claude AI)
# Optimized translation of my older PARI/GP program.
# Date: 26 November 2026
# https://oeis.org/A007011

# Smallest Fermat pseudoprime to base 2 with exactly n distinct prime factors
# (OEIS A007011):  the least composite m with omega(m) = n and 2^(m-1) == 1 (mod m).
#
# Requires Math::Prime::Util >= 0.74 and Math::GMPz.
#
# How the search works
# --------------------
# n = p_1^e_1 * ... * p_k^e_k is a base-2 Fermat pseudoprime iff ord_{p^e}(2) | n-1 for
# every p^e || n.  For e = 1 this order is z_p = ord_p(2) (which divides p-1); for e >= 2
# it is z_p only if p is a Wieferich prime (2^z_p == 1 mod p^e), otherwise p | ord_{p^e}(2)
# and p | n would contradict ord | n-1.
#
# Squarefree part.  The primes p_1 < ... < p_(k-1) are chosen by depth-first search; with
# m = p_1*...*p_j and L = lcm(z_p_1, ..., z_p_j), every completion n = m*q needs
# n == 1 (mod L).  Shortcuts:
#
#   * forced completion: q must be one of the numbers  first + t*L  in [q_min, q_max],
#     where first = m^(-1) mod L; if there are few of them they are factored directly
#     and every prime s of q is tested with 2^(n-1) == 1 (mod s);
#   * the last prime p_k: since z_p | p-1, the condition z_p | n-1 is equivalent to
#     z_p | m-1, i.e. 2^(m-1) == 1 (mod p_k); together with p_k == m^(-1) (mod L) this
#     is either the single residue in its window or a short progression that is walked;
#   * the last two levels (the loop over p_(k-1) and the terminal prime) are inlined;
#   * the cofactor lower bound uses the consecutive primes of the list.
#
# Prime powers.  Only Wieferich primes (2^z_p == 1 mod p^2; 1093 and 3511 are the only known
# ones) can occur with exponent >= 2.  Every prime that can occur is checked while the prime
# table is built.  Each combination "w^e | n" is a separate run that starts from the given
# multiple m_0 = prod w^e, with the primes dividing m_0 or lcm(z_w) removed from the list.
#
# Interval search.  The intervals [lower, upper] are contiguous and doubling, so the first
# interval containing a solution contains the global minimum.  Inside an interval the upper
# bound is lowered to (best - 1) every time something is found, which prunes the rest of
# the search (including the loop bounds of the nodes that are already on the stack).
#
# Facts used:
#   * all primes are odd (an even n cannot satisfy 2^(n-1) == 1 mod n);
#   * gcd(m, z_p) = 1 is necessary (a prime of m would divide both n and n-1);
#   * L divides n-1, hence L < B.

use v5.36;
use strict;
use warnings;

no warnings 'recursion';

use Math::GMPz qw(:mpz);
use Math::Prime::Util 0.74 qw(:all);

sub fermat_psp_base2_smallest ($num_factors) {

    die "n must be an integer >= 2\n" if (!defined($num_factors) || $num_factors < 2);
    $num_factors += 0;

    my $force_bits  = 64;
    my $force_count = 16;
    my $force_ratio = 0.75;

    my $TWO  = Rmpz_init_set_ui(2);
    my $ONE  = Rmpz_init_set_ui(1);
    my $NULL = $Math::GMPz::NULL;

    my $bound     = Rmpz_init();    # inclusive upper bound; lowered when a candidate is found
    my $best      = Rmpz_init();
    my $found     = 0;
    my $bound_gen = 0;

    my (@primes_table, @orders_table, @wieferich);
    my $table_max = 2;

    # Shared scratch mpz variables
    my ($tmp1,     $tmp2,      $tmp3, $inv_q, $cand_q,   $n_minus_1, $cand_n, $rem_mod) = map { Rmpz_init() } 1 .. 8;
    my ($tail_lcm, $tail_prod, $q_hi, $q_lo,  $tail_exp, $term_q,    $term_n, $step)    = map { Rmpz_init() } 1 .. 8;

    my sub record_solution ($candidate) {
        Rmpz_set($best, $candidate);
        Rmpz_sub_ui($bound, $candidate, 1);
        $found = 1;
        ++$bound_gen;
    }

    my sub mpz_is_prime ($val) {
        return is_prime(Rmpz_fits_ulong_p($val) ? Rmpz_get_ui($val) : Rmpz_get_str($val, 10));
    }

    # Largest e >= 1 such that 2^ord_p(2) == 1 (mod p^e). e >= 2 indicates a Wieferich prime.
    my sub wieferich_exponent ($prime, $ord) {

        if ($prime < 4294967296) {    # p*p fits into 64 bits
            return 1 if powmod(2, $ord, $prime * $prime) != 1;
        }

        my $p_pow = Rmpz_init_set_ui($prime);
        my $ord_z = Rmpz_init_set_ui($ord);
        my $res   = Rmpz_init();
        my $exp   = 1;

        while (1) {
            Rmpz_mul_ui($p_pow, $p_pow, $prime);
            Rmpz_powm($res, $TWO, $ord_z, $p_pow);
            last if Rmpz_cmp_ui($res, 1) != 0;
            ++$exp;
        }

        return $exp;
    }

    my sub extend_prime_tables ($limit) {
        return if $limit <= $table_max;

        for my $p (@{primes($table_max + 1, $limit)}) {
            my $ord = znorder(2, $p);
            push @primes_table, $p;
            push @orders_table, $ord;
            my $exp = wieferich_exponent($p, $ord);
            push @wieferich, [$p, $exp, $ord] if $exp > 1;
        }

        $table_max = $limit;
    }

    my sub sieve_limit_for ($min_prefixes, $sqfree_count) {

        my $limit = Rmpz_init_set_ui(3);
        for my $depth (0 .. $sqfree_count - 2) {
            Rmpz_fdiv_q($tmp1, $bound, $min_prefixes->[$depth]);
            Rmpz_root($tmp1, $tmp1, $sqfree_count - $depth);
            Rmpz_set($limit, $tmp1) if Rmpz_cmp($tmp1, $limit) > 0;
        }

        die "Range too large\n" if !Rmpz_fits_ulong_p($limit);

        my $sieve_max = Rmpz_get_ui($limit);
        extend_prime_tables($sieve_max);
        return $sieve_max;
    }

    my sub search_combo ($min_val_in, $base_prod, $base_lcm, $wieferich_count) {

        my $sqfree_count = $num_factors - $wieferich_count;
        return if $sqfree_count < 2;
        return if Rmpz_cmp($base_prod, $bound) > 0;

        my $has_base = Rmpz_cmp_ui($base_prod, 1) > 0 ? 1 : 0;

        Rmpz_gcd($tmp1, $base_prod, $base_lcm);
        return if Rmpz_cmp_ui($tmp1, 1) != 0;

        # min_prefixes[$j] = smallest possible m after picking $j squarefree primes
        my @min_prefixes = (Rmpz_init_set($base_prod));
        my $candidate_p  = 2;
        for my $j (1 .. $sqfree_count) {
            do { $candidate_p = next_prime($candidate_p) } while Rmpz_divisible_ui_p($base_prod, $candidate_p) || Rmpz_divisible_ui_p($base_lcm, $candidate_p);
            my $next_min = Rmpz_init();
            Rmpz_mul_ui($next_min, $min_prefixes[$j - 1], $candidate_p);
            return if Rmpz_cmp($next_min, $bound) > 0;
            push @min_prefixes, $next_min;
        }

        my $min_val       = Rmpz_init_set($min_val_in);
        my $min_val_binds = Rmpz_cmp($min_val, $min_prefixes[$sqfree_count]) > 0 ? 1 : 0;
        Rmpz_set($min_val, $min_prefixes[$sqfree_count]) if !$min_val_binds;

        my $sieve_max = sieve_limit_for(\@min_prefixes, $sqfree_count);

        my (@allowed_p, @allowed_ord);
        for my $idx (0 .. $#primes_table) {
            my $p = $primes_table[$idx];
            last if $p > $sieve_max;
            next if $has_base && (Rmpz_divisible_ui_p($base_prod, $p) || Rmpz_divisible_ui_p($base_lcm, $p));
            push @allowed_p,   $p;
            push @allowed_ord, $orders_table[$idx];
        }
        push @allowed_p,   $sieve_max + 1;    # sentinel above all valid prime bounds
        push @allowed_ord, 1;

        my @cur_prod = map { Rmpz_init() } 0 .. $sqfree_count;
        my @cur_lcm  = map { Rmpz_init() } 0 .. $sqfree_count;
        my @cof_max  = map { Rmpz_init() } 0 .. $sqfree_count;
        my @cof_min  = map { Rmpz_init() } 0 .. $sqfree_count;
        my @cof_low  = map { Rmpz_init() } 0 .. $sqfree_count;
        Rmpz_set($cur_prod[0], $base_prod);
        Rmpz_set($cur_lcm[0],  $base_lcm);

        sub ($depth, $p_idx, $remaining) {

            my $prod = $cur_prod[$depth];
            my $lcm  = $cur_lcm[$depth];
            my $qmax = $cof_max[$depth];
            my $qmin = $cof_min[$depth];
            my $qlow = $cof_low[$depth];

            Rmpz_fdiv_q($qmax, $bound, $prod);

            my $p_lo = $allowed_p[$p_idx];
            Rmpz_root($tmp1, $qmax, $remaining);
            my $p_hi = Rmpz_get_ui($tmp1);
            return if $p_lo > $p_hi;

            Rmpz_set_ui($qmin, $p_lo);
            Rmpz_mul_ui($qmin, $qmin, $allowed_p[$p_idx + $_ > $#allowed_p ? $#allowed_p : $p_idx + $_])
              for 1 .. $remaining - 1;
            return if Rmpz_cmp($qmin, $qmax) > 0;

            if ($min_val_binds) {
                Rmpz_cdiv_q($qlow, $min_val, $prod);
                if (Rmpz_cmp($qlow, $qmin) > 0) {
                    Rmpz_set($qmin, $qlow);
                    return if Rmpz_cmp($qmin, $qmax) > 0;
                }
            }

            # Forced completion: cofactor q == prod^(-1) (mod lcm) in [qmin, qmax]
            if (Rmpz_cmp_ui($lcm, 1) > 0) {

                Rmpz_invert($inv_q, $prod, $lcm) or die "Internal error: modular inverse does not exist\n";

                if (Rmpz_cmp($inv_q, $qmin) < 0) {
                    Rmpz_sub($tmp1, $qmin, $inv_q);
                    Rmpz_cdiv_q($tmp1, $tmp1, $lcm);
                    Rmpz_addmul($inv_q, $tmp1, $lcm);
                }

                return if Rmpz_cmp($inv_q, $qmax) > 0;

                Rmpz_sub($tmp1, $qmax, $inv_q);
                Rmpz_fdiv_q($tmp1, $tmp1, $lcm);

                if (Rmpz_fits_ulong_p($tmp1) && Rmpz_sizeinbase($qmax, 2) <= $force_bits) {

                    my $cand_count = Rmpz_get_ui($tmp1) + 1;
                    my $threshold  = $force_count;

                    if ($force_ratio > 0) {
                        my $est_primes = $p_hi > $p_lo ? ($p_hi / log($p_hi) - $p_lo / log($p_lo > 2 ? $p_lo : 3)) : 1;
                        $est_primes = 1 if $est_primes < 1;
                        my $ratio_thr = $force_ratio * $est_primes;
                        $threshold = $ratio_thr if $ratio_thr > $threshold;
                    }

                    if ($cand_count <= $threshold) {
                        Rmpz_set($cand_q, $inv_q);

                        while (Rmpz_cmp($cand_q, $qmax) <= 0) {
                            my $q_val = Rmpz_fits_ulong_p($cand_q) ? Rmpz_get_ui($cand_q) : Rmpz_get_str($cand_q, 10);

                            if (is_rough($q_val, $p_lo) && is_almost_prime($remaining, $q_val)) {
                                my @factors = factor_exp($q_val);
                                if (@factors == $remaining && $factors[0][0] >= $p_lo) {
                                    my $valid = 1;
                                    Rmpz_mul($cand_n, $prod, $cand_q);
                                    Rmpz_sub_ui($n_minus_1, $cand_n, 1);

                                    for my $pe (@factors) {
                                        my ($fac_p, $fac_e) = @$pe;
                                        if ($fac_e != 1) { $valid = 0; last }
                                        Rmpz_set_str($tmp3, "$fac_p", 10);
                                        if ($has_base && Rmpz_divisible_p($base_prod, $tmp3)) { $valid = 0; last }
                                        Rmpz_powm($rem_mod, $TWO, $n_minus_1, $tmp3);
                                        if (Rmpz_cmp_ui($rem_mod, 1) != 0) { $valid = 0; last }
                                    }

                                    if ($valid) {
                                        record_solution($cand_n);
                                        return;
                                    }
                                }
                            }
                            Rmpz_add($cand_q, $cand_q, $lcm);
                        }
                        return;
                    }
                }
            }

            if ($remaining > 2) {
                my $next_prod = $cur_prod[$depth + 1];
                my $next_lcm  = $cur_lcm[$depth + 1];
                my $seen_gen  = $bound_gen;

                for (my $i = $p_idx ; ; ++$i) {
                    my $p = $allowed_p[$i];
                    last if $p > $p_hi;
                    my $ord = $allowed_ord[$i];

                    next if Rmpz_gcd_ui($NULL, $prod, $ord) != 1;

                    Rmpz_lcm_ui($next_lcm, $lcm, $ord);
                    next if Rmpz_cmp($next_lcm, $bound) >= 0;

                    Rmpz_mul_ui($next_prod, $prod, $p);
                    __SUB__->($depth + 1, $i + 1, $remaining - 1);

                    if ($seen_gen != $bound_gen) {
                        $seen_gen = $bound_gen;
                        Rmpz_fdiv_q($qmax, $bound, $prod);
                        Rmpz_root($tmp1, $qmax, $remaining);
                        $p_hi = Rmpz_get_ui($tmp1);
                    }
                }
                return;
            }

            # Tail case: two squarefree primes left ($p and terminal prime $term_q)
            for (my $i = $p_idx ; ; ++$i) {
                my $p = $allowed_p[$i];
                last if $p > $p_hi;

                Rmpz_lcm_ui($tail_lcm, $lcm, $allowed_ord[$i]);
                Rmpz_mul_ui($tail_prod, $prod, $p);

                Rmpz_invert($term_q, $tail_prod, $tail_lcm) or next;

                Rmpz_fdiv_q_ui($q_hi, $qmax, $p);
                next if Rmpz_cmp($term_q, $q_hi) > 0;

                if (Rmpz_tstbit($tail_lcm, 0)) {
                    Rmpz_add($term_q, $term_q, $tail_lcm) if !Rmpz_tstbit($term_q, 0);
                    Rmpz_mul_2exp($step, $tail_lcm, 1);
                }
                else {
                    Rmpz_set($step, $tail_lcm);
                }

                Rmpz_set_ui($q_lo, $p + 2);
                if ($min_val_binds) {
                    Rmpz_cdiv_q_ui($tmp2, $qlow, $p);
                    Rmpz_set($q_lo, $tmp2) if Rmpz_cmp($tmp2, $q_lo) > 0;
                }

                if (Rmpz_cmp($term_q, $q_lo) < 0) {
                    Rmpz_sub($tmp2, $q_lo, $term_q);
                    Rmpz_cdiv_q($tmp2, $tmp2, $step);
                    Rmpz_addmul($term_q, $tmp2, $step);
                }
                next if Rmpz_cmp($term_q, $q_hi) > 0;

                Rmpz_sub_ui($tail_exp, $tail_prod, 1);

                my $hit = 0;
                if (Rmpz_fits_ulong_p($tail_exp) && Rmpz_fits_ulong_p($q_hi) && Rmpz_fits_ulong_p($step)) {
                    my ($q_cur, $q_end, $q_step, $exp_ui) =
                      (Rmpz_get_ui($term_q), Rmpz_get_ui($q_hi), Rmpz_get_ui($step), Rmpz_get_ui($tail_exp));
                    for (; $q_cur <= $q_end ; $q_cur += $q_step) {
                        if (powmod(2, $exp_ui, $q_cur) == 1 && is_prime($q_cur)) {
                            next if $has_base && Rmpz_divisible_ui_p($base_prod, $q_cur);
                            Rmpz_mul_ui($term_n, $tail_prod, $q_cur);
                            $hit = 1;
                            last;
                        }
                    }
                }
                else {
                    while (Rmpz_cmp($term_q, $q_hi) <= 0) {
                        Rmpz_powm($rem_mod, $TWO, $tail_exp, $term_q);
                        if (   Rmpz_cmp_ui($rem_mod, 1) == 0
                            && !($has_base && Rmpz_divisible_p($base_prod, $term_q))
                            && mpz_is_prime($term_q)) {
                            Rmpz_mul($term_n, $tail_prod, $term_q);
                            $hit = 1;
                            last;
                        }
                        Rmpz_add($term_q, $term_q, $step);
                    }
                }

                if ($hit) {
                    record_solution($term_n);
                    Rmpz_fdiv_q($qmax, $bound, $prod);
                    Rmpz_root($tmp1, $qmax, 2);
                    $p_hi = Rmpz_get_ui($tmp1);
                }
            }
        }->(0, 0, $sqfree_count);
    }

    my sub search_interval ($interval_min) {

        search_combo($interval_min, $ONE, $ONE, 0);

        my @combos = ([$ONE, $ONE, 0]);

        for my $w (@wieferich) {
            my ($p, $max_exp, $ord) = @$w;
            my @next_combos;
            for my $cb (@combos) {
                my ($m0, $l0, $w_cnt) = @$cb;
                for my $e (2 .. $max_exp) {
                    my $nm = Rmpz_init();
                    Rmpz_ui_pow_ui($nm, $p, $e);
                    Rmpz_mul($nm, $nm, $m0);
                    my $nl = Rmpz_init_set_ui($ord);
                    Rmpz_lcm($nl, $nl, $l0);
                    push @next_combos, [$nm, $nl, $w_cnt + 1];
                }
            }
            push @combos, @next_combos;
        }

        shift @combos;

        for my $cb (@combos) {
            search_combo($interval_min, @$cb);
        }
    }

    my $lower = Rmpz_init_set_ui(1);
    {
        my $p = 2;
        for (1 .. $num_factors) {
            $p = next_prime($p);
            Rmpz_mul_ui($lower, $lower, $p);
        }
    }

    my $upper = Rmpz_init();
    Rmpz_mul_2exp($upper, $lower, 1);

    while (1) {
        Rmpz_set($bound, $upper);
        $found = 0;

        search_interval($lower);

        return Rmpz_init_set($best) if $found;

        Rmpz_add_ui($lower, $upper, 1);
        Rmpz_mul_2exp($upper, $upper, 1);
    }
}

for my $n (2 .. 20) {
    my $term = fermat_psp_base2_smallest($n);
    say "a($n) = $term";
}
