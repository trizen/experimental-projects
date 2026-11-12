#!/usr/bin/env perl

# Least Carmichael number with exactly n distinct prime factors, all 3 mod 4.
#
# Usage:
#   perl carmichael_3mod4.pl [n] [--force-bits=B] [--force-count=C]
#
#   --force-bits=B    "forced completion" only factors cofactors Q with at most B bits
#   --force-count=C   ... and only when at most C candidates Q remain

# a(18) = 461989623348544171457304879927675763501
# perl carmichael_3mod4.pl 18  1691.07s user 0.22s system 99% cpu 28:13.39 total

use 5.014;
use strict;
use warnings;
no warnings 'recursion';

use Getopt::Long qw(GetOptions);
use Time::HiRes  qw(time);

use Math::GMPz             qw(:mpz);
use Math::Prime::Util      qw(is_prime primes);
use Math::Prime::Util::GMP ();

# --------------------------------------------------------------------------
# Options
# --------------------------------------------------------------------------

my $FORCE_BITS  = 64;
my $FORCE_COUNT = 16;

GetOptions('force-bits=i'  => \$FORCE_BITS,
           'force-count=i' => \$FORCE_COUNT,)
  or die "Usage: $0 [n] [--force-bits=B] [--force-count=C]\n";

my $target_n = @ARGV ? int($ARGV[0]) : 14;

if ($target_n < 3) {
    print STDERR "Usage: $0 [n], with n >= 3\n";
    exit 2;
}

# --------------------------------------------------------------------------
# Global state. All Math::GMPz objects are allocated once, up front.
# --------------------------------------------------------------------------

sub Z { Rmpz_init() }

my @P;                  # primes congruent to 3 mod 4 (native integers)
my $lower     = Z();    # current interval [lower, upper]
my $upper     = Z();
my $upper_m1  = Z();    # upper - 1
my $best      = Z();    # best N found so far (valid iff $have_best)
my $have_best = 0;

my ($visited_nodes, $forced_nodes, $terminal_nodes, $factorizations) = (0, 0, 0, 0);

# Per-depth objects (these must survive the recursive call, so one set per level).
my (@M, @L, @MC);
for my $d (0 .. $target_n) {
    $M[$d]  = Z();    # m  = product of chosen primes
    $L[$d]  = Z();    # lcm of (p-1) over chosen primes
    $MC[$d] = Z();    # minimum possible completion
}
Rmpz_set_ui($M[0], 1);
Rmpz_set_ui($L[0], 1);

# Scratch objects. Each routine has its own set, because search_dfs calls
# try_forced_completion, which calls test_forced_product.
my ($S_qmin, $S_qmax, $S_pmax, $S_g)                               = map { Z() } 1 .. 4;    # search_dfs (non-terminal)
my ($R_pmax, $R_pmin, $R_res, $R_step, $R_t, $R_m1, $R_pp, $R_pm1) = map { Z() } 1 .. 8;    # search_dfs (rem == 1)
my ($F_qmin, $F_t, $F_step, $F_first, $F_q)                        = map { Z() } 1 .. 5;    # try_forced_completion
my ($T_resid, $T_full, $T_d, $T_N, $T_Nm1)                         = map { Z() } 1 .. 5;    # test_forced_product
my @F = map { Z() } 0 .. $target_n;                                                         # factors of Q

# --------------------------------------------------------------------------
# Verify that Q is a product of exactly `rem` distinct primes, all 3 mod 4 and
# >= lo. Then test Korselt's criterion using lcm(p_i - 1).
# $Q is a Math::GMPz object; $lo is a native integer.
# --------------------------------------------------------------------------

sub test_forced_product {
    my ($m, $old_lcm, $Q, $rem, $lo) = @_;

    return if Rmpz_sgn($Q) == 0;
    ++$factorizations;

    my $nf    = 0;
    my $resid = $T_resid;
    Rmpz_set($resid, $Q);

    if (Rmpz_cmp_ui($resid, 1) > 0) {
        foreach my $s (Math::Prime::Util::factor(Rmpz_get_str($resid, 10))) {
            return if (substr($s, -2) % 4) != 3;    # last two digits decide mod 4
            return if $nf >= $rem;
            Rmpz_set_str($F[$nf], "$s", 10);
            return if Rmpz_cmp_ui($F[$nf], $lo) < 0;
            ++$nf;
        }
    }

    return if $nf != $rem;

    # Factors are in ascending order: any repeated prime shows up as a non-increase.
    for my $i (1 .. $rem - 1) {
        return if Rmpz_cmp($F[$i - 1], $F[$i]) >= 0;
    }

    my ($full, $d) = ($T_full, $T_d);
    Rmpz_set($full, $old_lcm);
    for my $i (0 .. $rem - 1) {
        Rmpz_sub_ui($d, $F[$i], 1);
        Rmpz_lcm($full, $full, $d);
        return if Rmpz_cmp($full, $upper_m1) > 0;    # lcm must divide N-1 < upper
    }

    my $N = $T_N;
    Rmpz_mul($N, $m, $Q);
    return if Rmpz_cmp($N, $lower) < 0 or Rmpz_cmp($N, $upper) > 0;

    Rmpz_sub_ui($T_Nm1, $N, 1);
    return if !Rmpz_divisible_p($T_Nm1, $full);

    if (!$have_best or Rmpz_cmp($N, $best) < 0) {
        Rmpz_set($best, $N);
        $have_best = 1;
    }
}

# --------------------------------------------------------------------------
# For the remaining product Q, the old Korselt conditions require
#     m*Q == 1 (mod old_lcm).
# If only a small number of such Q fit in the interval, factor them directly
# instead of branching on the remaining primes one at a time.
# Returns true when the whole subtree has been dealt with.
# $Qmin_in and $Qmax are Math::GMPz objects (neither is modified).
# --------------------------------------------------------------------------

sub try_forced_completion {
    my ($m, $old_lcm, $lo, $rem, $Qmin_in, $Qmax) = @_;

    return 0 if Rmpz_sgn($Qmax) == 0 or Rmpz_cmp_ui($old_lcm, 1) <= 0;

    my $Qmin = $F_qmin;
    Rmpz_set($Qmin, $Qmin_in);

    # Q >= ceil(lower / m)
    Rmpz_cdiv_q($F_t, $lower, $m);
    Rmpz_set($Qmin, $F_t) if Rmpz_cmp($Qmin, $F_t) < 0;
    return 1              if Rmpz_cmp($Qmin, $Qmax) > 0;    # nothing lies in this interval

    # old_lcm has exactly one factor 2 (every p is 3 mod 4, so p-1 = 2 mod 4),
    # hence the product Q has a fixed residue modulo 4.
    my $step = $F_step;
    Rmpz_mul_2exp($step, $old_lcm, 1);
    my $wanted_mod4 = ($rem & 1) ? 3 : 1;

    my $first = $F_first;
    Rmpz_invert($first, $m, $old_lcm)
      or die "modular inverse does not exist\n";
    Rmpz_add($first, $first, $old_lcm) if Rmpz_fdiv_ui($first, 4) != $wanted_mod4;

    if (Rmpz_cmp($first, $Qmin) < 0) {
        Rmpz_sub($F_t, $Qmin, $first);
        Rmpz_cdiv_q($F_t, $F_t, $step);    # jumps = ceil(delta / step)
        Rmpz_addmul($first, $F_t, $step);
    }
    return 1 if Rmpz_cmp($first, $Qmax) > 0;    # no Q in the required residue class

    # count = (Qmax - first) / step + 1.  Direct factoring is used only when it
    # is cheaper than continuing the DFS.
    Rmpz_sub($F_t, $Qmax, $first);
    Rmpz_fdiv_q($F_t, $F_t, $step);

    return 0
      if Rmpz_sizeinbase($Qmax, 2) > $FORCE_BITS
      or Rmpz_cmp_ui($F_t, $FORCE_COUNT - 1) > 0;

    ++$forced_nodes;
    my $q = $F_q;
    Rmpz_set($q, $first);
    while (Rmpz_cmp($q, $Qmax) <= 0) {
        if ($have_best) {
            Rmpz_mul($F_t, $m, $q);
            last if Rmpz_cmp($F_t, $best) >= 0;
        }
        test_forced_product($m, $old_lcm, $q, $rem, $lo);
        Rmpz_add($q, $q, $step);
    }
    return 1;    # every Q in the class was examined
}

# --------------------------------------------------------------------------
# Depth-first search.
#   $m, $old_lcm : Math::GMPz objects (not modified)
#   $lo          : smallest prime value still allowed (native integer)
#   $si          : index into @P of the first prime >= $lo
#   $rem         : number of primes still to choose
#   $d           : recursion depth (selects the preallocated per-level objects)
# --------------------------------------------------------------------------

sub search_dfs {
    my ($m, $old_lcm, $lo, $si, $rem, $d) = @_;

    ++$visited_nodes;

    # ---- last prime: scan the residue class p = m^-1 (mod old_lcm), p = 3 (mod 4)
    if ($rem == 1) {
        ++$terminal_nodes;

        my ($pmax, $pmin, $res, $step, $t, $m1) = ($R_pmax, $R_pmin, $R_res, $R_step, $R_t, $R_m1);

        Rmpz_fdiv_q($pmax, $upper, $m);
        Rmpz_set($pmax, $m) if Rmpz_cmp($pmax, $m) > 0;    # p-1 | m-1 implies p <= m

        if ($have_best) {                                  # only N < best is interesting
            Rmpz_sub_ui($t, $best, 1);
            Rmpz_fdiv_q($t, $t, $m);
            Rmpz_set($pmax, $t) if Rmpz_cmp($t, $pmax) < 0;
        }

        Rmpz_cdiv_q($pmin, $lower, $m);
        Rmpz_set_ui($pmin, $lo) if Rmpz_cmp_ui($pmin, $lo) < 0;
        return                  if Rmpz_cmp($pmin, $pmax) > 0;

        Rmpz_invert($res, $m, $old_lcm)
          or die "modular inverse does not exist\n";
        Rmpz_add($res, $res, $old_lcm) if Rmpz_fdiv_ui($res, 4) != 3;
        Rmpz_mul_2exp($step, $old_lcm, 1);

        if (Rmpz_cmp($res, $pmin) < 0) {
            Rmpz_sub($t, $pmin, $res);
            Rmpz_cdiv_q($t, $t, $step);
            Rmpz_addmul($res, $t, $step);
        }
        return if Rmpz_cmp($res, $pmax) > 0;

        # (m*p - 1) % (p - 1) == 0  iff  (m - 1) % (p - 1) == 0.
        # Since lower/m <= p <= upper/m and p < best/m, N = m*p is automatically in range.
        Rmpz_sub_ui($m1, $m, 1);

        if (Rmpz_fits_ulong_p($pmax)) {

            # Fast path: p fits in a native unsigned integer.
            my $p  = Rmpz_get_ui($res);
            my $pm = Rmpz_get_ui($pmax);
            my $st = Rmpz_fits_ulong_p($step) ? Rmpz_get_ui($step) : die "step too large";
            while (1) {
                if (Rmpz_divisible_ui_p($m1, $p - 1) and is_prime($p)) {
                    Rmpz_mul_ui($best, $m, $p);
                    $have_best = 1;
                    last;    # later p only give larger N
                }
                last if $st > $pm - $p;
                $p += $st;
            }
        }
        else {
            # General path: p may exceed 64 bits.
            my ($pp, $pm1) = ($R_pp, $R_pm1);
            Rmpz_set($pp, $res);
            while (Rmpz_cmp($pp, $pmax) <= 0) {
                Rmpz_sub_ui($pm1, $pp, 1);
                if (    Rmpz_divisible_p($m1, $pm1)
                    and Math::Prime::Util::GMP::is_prime(Rmpz_get_str($pp, 10))) {
                    Rmpz_mul($best, $m, $pp);
                    $have_best = 1;
                    last;
                }
                Rmpz_add($pp, $pp, $step);
            }
        }
        return;
    }

    # ---- minimum possible product of the `rem` remaining primes
    my ($qmin, $qmax) = ($S_qmin, $S_qmax);
    Rmpz_set_ui($qmin, 1);
    for my $i ($si .. $si + $rem - 1) {
        return if $i > $#P;
        Rmpz_mul_ui($qmin, $qmin, $P[$i]);
        return if Rmpz_cmp($qmin, $upper) > 0;
    }

    Rmpz_fdiv_q($qmax, $upper, $m);
    return if Rmpz_cmp($qmin, $qmax) > 0;

    # If old_lcm > qmax, the remaining product Q is uniquely determined.
    if (Rmpz_cmp($old_lcm, $qmax) > 0 and Rmpz_sizeinbase($qmax, 2) <= $FORCE_BITS) {
        try_forced_completion($m, $old_lcm, $lo, $rem, $qmin, $qmax);
        return;
    }

    return if try_forced_completion($m, $old_lcm, $lo, $rem, $qmin, $qmax);

    Rmpz_root($S_pmax, $qmax, $rem);    # floor(qmax^(1/rem))
    return if Rmpz_cmp_ui($S_pmax, $lo) < 0;
    my $pmax = Rmpz_fits_ulong_p($S_pmax) ? Rmpz_get_ui($S_pmax) : ~0;

    my ($mp, $new_lcm, $min_completion, $g) = ($M[$d + 1], $L[$d + 1], $MC[$d], $S_g);
    my $last = $#P;

    for (my $i = $si ; $i <= $last ; ++$i) {
        my $p = $P[$i];
        last if $p > $pmax;

        my $pm1 = $p - 1;
        next if Rmpz_gcd_ui($g, $m, $pm1) != 1;

        # lcm(old_lcm, p-1); it must stay below upper (it divides N-1).
        Rmpz_lcm_ui($new_lcm, $old_lcm, $pm1);
        next if Rmpz_cmp($new_lcm, $upper) >= 0;

        Rmpz_mul_ui($mp, $m, $p);

        # Minimum completion after choosing p: use the next rem-1 primes.
        Rmpz_set($min_completion, $mp);
        my $impossible = 0;
        for my $j ($i + 1 .. $i + $rem - 1) {
            if ($j > $last) { $impossible = 1; last }
            Rmpz_mul_ui($min_completion, $min_completion, $P[$j]);
            if (Rmpz_cmp($min_completion, $upper) > 0) { $impossible = 1; last }
        }
        last if $impossible;

        search_dfs($mp, $new_lcm, $p + 1, $i + 1, $rem - 1, $d + 1);

        # Later p only increase the minimum possible completion.
        last if $have_best and Rmpz_cmp($min_completion, $best) >= 0;
    }
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

# First n primes congruent to 3 mod 4.
my @first_primes;
for (my $x = 3 ; @first_primes < $target_n ; $x += 2) {
    push @first_primes, $x if ($x & 3) == 3 and is_prime($x);
}

# min_prefix[i] = product of the first i such primes.
my @min_prefix = map { Z() } 0 .. $target_n;
Rmpz_set_ui($min_prefix[0], 1);
for my $i (1 .. $target_n) {
    Rmpz_mul_ui($min_prefix[$i], $min_prefix[$i - 1], $first_primes[$i - 1]);
}

# Every admissible number is at least the product of the first n such primes.
Rmpz_set($lower, $min_prefix[$target_n]);
Rmpz_mul_2exp($upper, $lower, 1);
print STDERR "minimum possible product = ", Rmpz_get_str($lower, 10), "\n";

my $tmp = Z();

for (; ;) {
    Rmpz_sub_ui($upper_m1, $upper, 1);

    # Global upper bound for every non-terminal prime loop.
    my $sieve_limit = $first_primes[-1] > 3 ? $first_primes[-1] : 3;
    for my $d (0 .. $target_n - 2) {
        my $rem = $target_n - $d;
        Rmpz_fdiv_q($tmp, $upper, $min_prefix[$d]);
        Rmpz_root($tmp, $tmp, $rem);
        die "Error: sieve limit exceeds the native integer range\n"
          if !Rmpz_fits_ulong_p($tmp);
        my $r = Rmpz_get_ui($tmp);
        $sieve_limit = $r if $r > $sieve_limit;
    }

    # Add target_n+2 more primes after sieve_limit. They are needed to compute
    # the smallest possible suffix after a loop-bound prime.
    my $sieve_max = $sieve_limit;
    my $extra     = 0;
    my $x         = $sieve_limit + 1;
    ++$x while ($x & 3) != 3;
    for (; $extra < $target_n + 2 ; $x += 4) {
        if (is_prime($x)) {
            $sieve_max = $x;
            ++$extra;
        }
    }

    @P = grep { ($_ & 3) == 3 } @{primes($sieve_max)};

    $have_best = 0;
    ($visited_nodes, $forced_nodes, $terminal_nodes, $factorizations) = (0, 0, 0, 0);

    my $start = time();
    search_dfs($M[0], $L[0], 3, 0, $target_n, 0);
    my $elapsed = time() - $start;

    printf STDERR "[%s, %s] sieve=%s nodes=%s forced=%s factorizations=%s terminal=%s time=%.3f s",
      Rmpz_get_str($lower, 10), Rmpz_get_str($upper, 10), $sieve_limit,
      $visited_nodes, $forced_nodes, $factorizations, $terminal_nodes, $elapsed;

    if ($have_best) {
        my $s = Rmpz_get_str($best, 10);
        print STDERR " FOUND\n";
        print "a($target_n) = $s\n";
        exit 0;
    }
    print STDERR " none\n";

    # The intervals are contiguous and disjoint, so the first interval
    # containing a solution contains the global minimum.
    Rmpz_add_ui($lower, $upper, 1);
    Rmpz_mul_2exp($upper, $upper, 1);
}
