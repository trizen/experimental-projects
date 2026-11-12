#!/usr/bin/env perl

# Least Lucas-Carmichael number with exactly n distinct prime factors
# (OEIS A216928).
#
# A Lucas-Carmichael number is an odd squarefree composite N such that
# p+1 divides N+1 for every prime p dividing N.
#
# Usage:
#   perl lucas_carmichael.pl [n]
#       [--force-bits=B] [--force-count=C]
#
# The optional forced-completion optimization factors a small number of
# possible remaining cofactors instead of descending further into the DFS.

# New terms:
#   a(36) = 8828853655203578689430381589036872973425959414498544735979301597067270399
#   a(37) = 2347344001774550333260776315257231349217342743536447214704558547017743679999
#   a(38) = 604061742212138398323337907473368260331562553371604493245585843129530022995199
#   a(39) = 266292952726627395392316224855168968836365620723096866122452131292044042377241599
#   a(40) = 92899216486825993236043827392069872777867156506302258740807312682491880242758355199     (took 50 minutes)

use v5.36;
no warnings 'recursion';

use Getopt::Long qw(GetOptions Configure);
use Time::HiRes  qw(clock_gettime CLOCK_MONOTONIC);

use Math::GMPz             qw(:mpz);
use Math::Prime::Util      qw(factor_exp is_prime primes prime_set_config);
use Math::Prime::Util::GMP ();

# Keep MPU's bigint conversions on the same GMP representation as the search.
prime_set_config(bigint => 'Math::GMPz');

# ---------------------------------------------------------------------------
# Command-line options
# ---------------------------------------------------------------------------

my ($force_bits, $force_count, $help) = (64, 16, 0);

Configure(qw(no_auto_abbrev no_ignore_case));
GetOptions(
           'force-bits=i'  => \$force_bits,
           'force-count=i' => \$force_count,
           'help|h'        => \$help,
          )
  or usage(2);

usage(0) if $help;

my $n_arg = shift(@ARGV) // '8';
usage(2) if @ARGV || $n_arg !~ /\A[0-9]+\z/;

my $target_n = 0 + $n_arg;
usage(2) if $target_n < 3;

if ($force_bits < 1) {
    warn "--force-bits must be a positive integer\n";
    usage(2);
}
if ($force_count < 1) {
    warn "--force-count must be a positive integer\n";
    usage(2);
}

sub usage ($status = 0) {
    my $fh = $status ? *STDERR : *STDOUT;
    print {$fh} <<"USAGE";
Usage:
  perl $0 [n]
      [--force-bits=B] [--force-count=C] [--help]

Find the least Lucas-Carmichael number with exactly n distinct prime factors.

  --force-bits=B    factor candidate cofactors having at most B bits (64)
  --force-count=C   factor at most C candidate cofactors at a search node (16)
  --help            show this help
USAGE
    exit $status;
}

sub new_z () { Rmpz_init() }

# ---------------------------------------------------------------------------
# Search state
# ---------------------------------------------------------------------------

my @primes_odd;

my $lower       = new_z();    # Current inclusive interval [lower, upper].
my $upper       = new_z();
my $upper_plus1 = new_z();
my $best        = new_z();
my $have_best   = 0;

my ($visited_nodes, $forced_nodes, $terminal_nodes, $factorizations) = (0, 0, 0, 0);

# One product and one LCM per recursion depth.  A child never overwrites the
# objects passed to it by its parent.
my @product_at_depth = map { new_z() } 0 .. $target_n;
my @lcm_at_depth     = map { new_z() } 0 .. $target_n;
my @min_completion   = map { new_z() } 0 .. $target_n;

Rmpz_set_ui($product_at_depth[0], 1);
Rmpz_set_ui($lcm_at_depth[0],     1);

# Scratch objects are separated by routine because the forced-completion
# path calls test_forced_product(), and the DFS is recursive.
my ($q_min, $q_max, $next_prime_max, $gcd_scratch, $best_q_max)                          = map { new_z() } 1 .. 5;
my ($p_max, $p_min, $residue, $step, $terminal_t, $m_minus1, $terminal_p, $terminal_pp1) = map { new_z() } 1 .. 8;
my ($forced_q_min, $forced_q_max, $forced_t, $forced_step, $forced_first, $forced_q)     = map { new_z() } 1 .. 6;
my ($full_lcm, $factor_plus1, $candidate_n, $candidate_np1)                              = map { new_z() } 1 .. 4;
my @forced_factors = map { new_z() } 0 .. $target_n;

# ---------------------------------------------------------------------------
# Verify a forced cofactor and test the Lucas-Korselt criterion.
# ---------------------------------------------------------------------------

sub test_forced_product ($m, $old_lcm, $q, $remaining, $smallest_factor) {
    return if Rmpz_sgn($q) <= 0;
    ++$factorizations;

    my @factorization = factor_exp(Math::GMPz::Rmpz_get_str($q, 10));
    return unless @factorization == $remaining;

    for my $i (0 .. $#factorization) {
        my ($factor, $exponent) = @{$factorization[$i]};
        return unless $exponent == 1;    # Q must be square-free.
        Rmpz_set_str($forced_factors[$i], "$factor", 10);
        return if Rmpz_cmp_ui($forced_factors[$i], $smallest_factor) < 0;
    }

    # lcm(p+1) divides N+1, so lcm(p+1) <= N+1 <= upper+1.
    Rmpz_set($full_lcm, $old_lcm);
    for my $i (0 .. $remaining - 1) {
        Rmpz_add_ui($factor_plus1, $forced_factors[$i], 1);
        Rmpz_lcm($full_lcm, $full_lcm, $factor_plus1);
        return if Rmpz_cmp($full_lcm, $upper_plus1) > 0;
    }

    Rmpz_mul($candidate_n, $m, $q);
    return if Rmpz_cmp($candidate_n, $lower) < 0;
    return if Rmpz_cmp($candidate_n, $upper) > 0;

    Rmpz_add_ui($candidate_np1, $candidate_n, 1);
    return unless Rmpz_divisible_p($candidate_np1, $full_lcm);

    if (!$have_best || Rmpz_cmp($candidate_n, $best) < 0) {
        Rmpz_set($best, $candidate_n);
        $have_best = 1;
    }

    return 1;
}

# ---------------------------------------------------------------------------
# Try to finish a subtree by factoring the few possible remaining products.
#
# The already selected prime factors impose m*q == -1 (mod old_lcm).  This is
# a single residue class modulo old_lcm; it is automatically odd because
# old_lcm is even and gcd(m, old_lcm) = 1.
#
# Return true if the whole subtree was examined or proved empty; return false
# when too many/too-large candidates remain and the caller should use the DFS.
# ---------------------------------------------------------------------------

sub try_forced_completion ($m, $old_lcm, $smallest_factor, $remaining, $q_min_in, $q_max_in) {
    return 0 if Rmpz_cmp_ui($old_lcm, 1) <= 0;
    return 0 if Rmpz_sgn($q_max_in) <= 0;

    Rmpz_set($forced_q_min, $q_min_in);
    Rmpz_set($forced_q_max, $q_max_in);

    # q >= ceil(lower / m).
    Rmpz_cdiv_q($forced_t, $lower, $m);
    Rmpz_set($forced_q_min, $forced_t)
      if Rmpz_cmp($forced_q_min, $forced_t) < 0;

    return 1 if Rmpz_cmp($forced_q_min, $forced_q_max) > 0;

    Rmpz_set($forced_step, $old_lcm);

    # q == -m^(-1) (mod old_lcm), taken in the range (0, old_lcm).
    Rmpz_invert($forced_first, $m, $old_lcm)
      or die "No modular inverse for m modulo old_lcm\n";
    Rmpz_sub($forced_first, $old_lcm, $forced_first);

    if (Rmpz_cmp($forced_first, $forced_q_min) < 0) {
        Rmpz_sub($forced_t, $forced_q_min, $forced_first);
        Rmpz_cdiv_q($forced_t, $forced_t, $forced_step);
        Rmpz_addmul($forced_first, $forced_t, $forced_step);
    }

    return 1 if Rmpz_cmp($forced_first, $forced_q_max) > 0;

    # Number of candidates minus one: floor((q_max - first) / step).
    Rmpz_sub($forced_t, $forced_q_max, $forced_first);
    Rmpz_fdiv_q($forced_t, $forced_t, $forced_step);

    return 0 if Rmpz_sizeinbase($forced_q_max, 2) > $force_bits;
    return 0 if Rmpz_cmp_ui($forced_t, $force_count - 1) > 0;

    ++$forced_nodes;
    Rmpz_set($forced_q, $forced_first);

    while (Rmpz_cmp($forced_q, $forced_q_max) <= 0) {
        if ($have_best) {
            Rmpz_mul($forced_t, $m, $forced_q);
            last if Rmpz_cmp($forced_t, $best) >= 0;
        }

        test_forced_product($m, $old_lcm, $forced_q, $remaining, $smallest_factor);
        Rmpz_add($forced_q, $forced_q, $forced_step);
    }

    return 1;
}

# ---------------------------------------------------------------------------
# Depth-first search.
#
# m, old_lcm: GMP integers; smallest_factor: native integer lower bound.
# prime_index: first possible index in @primes_odd.
# remaining: number of prime factors still to choose.
# depth: selects the preallocated product/LCM objects for the child node.
# ---------------------------------------------------------------------------

sub search_dfs ($m, $old_lcm, $smallest_factor, $prime_index, $remaining, $depth) {
    ++$visited_nodes;

    # ---- Final prime: solve the congruences directly and scan that progression.
    if ($remaining == 1) {
        ++$terminal_nodes;

        # p <= upper/m, and p+1 | m-1 implies p+1 <= m-1, i.e. p <= m-2.
        Rmpz_fdiv_q($p_max, $upper, $m);
        Rmpz_sub_ui($terminal_t, $m, 2);
        Rmpz_set($p_max, $terminal_t) if Rmpz_cmp($p_max, $terminal_t) > 0;

        # We only need N < best once a candidate has been found.
        if ($have_best) {
            Rmpz_sub_ui($terminal_t, $best, 1);
            Rmpz_fdiv_q($terminal_t, $terminal_t, $m);
            Rmpz_set($p_max, $terminal_t)
              if Rmpz_cmp($terminal_t, $p_max) < 0;
        }

        Rmpz_cdiv_q($p_min, $lower, $m);
        Rmpz_set_ui($p_min, $smallest_factor)
          if Rmpz_cmp_ui($p_min, $smallest_factor) < 0;
        return if Rmpz_cmp($p_min, $p_max) > 0;

        # p == -m^(-1) (mod old_lcm); this residue class is odd.
        Rmpz_invert($residue, $m, $old_lcm)
          or die "No modular inverse for m modulo old_lcm\n";
        Rmpz_sub($residue, $old_lcm, $residue);
        Rmpz_set($step, $old_lcm);

        if (Rmpz_cmp($residue, $p_min) < 0) {
            Rmpz_sub($terminal_t, $p_min, $residue);
            Rmpz_cdiv_q($terminal_t, $terminal_t, $step);
            Rmpz_addmul($residue, $terminal_t, $step);
        }

        return if Rmpz_cmp($residue, $p_max) > 0;

        # For N=m*p, the last Lucas-Korselt condition is
        #   p+1 | m*p+1  <=>  p+1 | m*(-1)+1  <=>  p+1 | m-1.
        Rmpz_sub_ui($m_minus1, $m, 1);

        # The native path is safe only when BOTH the candidate bound and the
        # progression step fit.  Otherwise use GMP; a large step is not fatal.
        if (   Rmpz_fits_ulong_p($p_max)
            && Rmpz_fits_ulong_p($step)) {
            my $p  = Rmpz_get_ui($residue);
            my $hi = Rmpz_get_ui($p_max);
            my $by = Rmpz_get_ui($step);

            while (1) {
                if (Rmpz_divisible_ui_p($m_minus1, $p + 1) && is_prime($p)) {
                    Rmpz_mul_ui($best, $m, $p);
                    $have_best = 1;
                    last;    # Candidates are increasing, so this is the best here.
                }

                last if $by > $hi - $p;
                $p += $by;
            }
        }
        else {
            Rmpz_set($terminal_p, $residue);

            while (Rmpz_cmp($terminal_p, $p_max) <= 0) {
                Rmpz_add_ui($terminal_pp1, $terminal_p, 1);

                if (Rmpz_divisible_p($m_minus1, $terminal_pp1) && is_prime($terminal_p)) {
                    Rmpz_mul($best, $m, $terminal_p);
                    $have_best = 1;
                    last;
                }

                Rmpz_add($terminal_p, $terminal_p, $step);
            }
        }

        return;
    }

    # ---- Minimum possible product of the remaining distinct primes.
    Rmpz_set_ui($q_min, 1);
    for my $i ($prime_index .. $prime_index + $remaining - 1) {
        return if $i > $#primes_odd;

        Rmpz_mul_ui($q_min, $q_min, $primes_odd[$i]);
        return if Rmpz_cmp($q_min, $upper) > 0;
    }

    # q_max = floor(upper/m), tightened to floor((best-1)/m) if possible.
    Rmpz_fdiv_q($q_max, $upper, $m);
    if ($have_best) {
        Rmpz_sub_ui($best_q_max, $best, 1);
        Rmpz_fdiv_q($best_q_max, $best_q_max, $m);
        Rmpz_set($q_max, $best_q_max) if Rmpz_cmp($best_q_max, $q_max) < 0;
    }

    return if Rmpz_cmp($q_min, $q_max) > 0;

    # Try the direct-factorization shortcut before branching on another prime.
    return if try_forced_completion($m, $old_lcm, $smallest_factor, $remaining, $q_min, $q_max);

    Rmpz_root($next_prime_max, $q_max, $remaining);
    return if Rmpz_cmp_ui($next_prime_max, $smallest_factor) < 0;

    die "Internal error: DFS prime bound exceeds the native sieve range\n"
      unless Rmpz_fits_ulong_p($next_prime_max);
    my $p_max_native = Rmpz_get_ui($next_prime_max);

    my $child_m   = $product_at_depth[$depth + 1];
    my $child_lcm = $lcm_at_depth[$depth + 1];
    my $min_full  = $min_completion[$depth];
    my $last      = $#primes_odd;

    for (my $i = $prime_index ; $i <= $last ; ++$i) {
        my $p = $primes_odd[$i];
        last if $p > $p_max_native;

        my $p_plus1 = $p + 1;

        # Necessary for m*q == -1 (mod p+1): gcd(m, p+1) must be 1.
        next if Rmpz_gcd_ui($gcd_scratch, $m, $p_plus1) != 1;

        Rmpz_lcm_ui($child_lcm, $old_lcm, $p_plus1);
        next if Rmpz_cmp($child_lcm, $upper_plus1) > 0;

        Rmpz_mul_ui($child_m, $m, $p);

        # Bound this branch by completing it with the next `remaining-1`
        # eligible primes.  If this already exceeds upper, later p cannot help.
        Rmpz_set($min_full, $child_m);
        my $impossible = 0;

        for my $j ($i + 1 .. $i + $remaining - 1) {
            if ($j > $last) {
                $impossible = 1;
                last;
            }

            Rmpz_mul_ui($min_full, $min_full, $primes_odd[$j]);
            if (Rmpz_cmp($min_full, $upper) > 0) {
                $impossible = 1;
                last;
            }
        }

        last if $impossible;

        search_dfs($child_m, $child_lcm, $p + 1, $i + 1, $remaining - 1, $depth + 1);

        # The minimum completion increases with p; no later branch can beat it.
        last if $have_best && Rmpz_cmp($min_full, $best) >= 0;
    }
}

# ---------------------------------------------------------------------------
# Main search
# ---------------------------------------------------------------------------

# The first n odd primes give the absolute lower bound.
my @first_primes;
for (my $p = 3 ; @first_primes < $target_n ; $p += 2) {
    push @first_primes, $p if is_prime($p);
}

# prefix_product[d] is the product of the first d allowed primes.
my @prefix_product = map { new_z() } 0 .. $target_n;
Rmpz_set_ui($prefix_product[0], 1);

for my $i (1 .. $target_n) {
    Rmpz_mul_ui($prefix_product[$i], $prefix_product[$i - 1], $first_primes[$i - 1]);
}

Rmpz_set($lower, $prefix_product[$target_n]);
Rmpz_mul_2exp($upper, $lower, 1);

print STDERR "Minimum possible product = ", Rmpz_get_str($lower, 10), "\n";

my $tmp = new_z();

while (1) {
    Rmpz_add_ui($upper_plus1, $upper, 1);

    # A global upper bound for every non-terminal prime loop.  At depth d,
    # m >= prefix_product[d], so p^remaining <= upper/prefix_product[d].
    my $sieve_limit = $first_primes[-1];

    for my $depth (0 .. $target_n - 2) {
        my $remaining = $target_n - $depth;

        Rmpz_fdiv_q($tmp, $upper, $prefix_product[$depth]);
        Rmpz_root($tmp, $tmp, $remaining);

        die "The required prime sieve limit exceeds the native integer range\n"
          unless Rmpz_fits_ulong_p($tmp);

        my $limit = Rmpz_get_ui($tmp);
        $sieve_limit = $limit if $limit > $sieve_limit;
    }

    # Keep enough primes beyond the global loop bound to construct the
    # minimum suffix after any possible loop-bound prime.
    my $sieve_max = $sieve_limit;
    my $extra     = 0;
    my $candidate = $sieve_limit + 1;

    ++$candidate if ($candidate & 1) == 0;

    while ($extra < $target_n + 2) {
        if (is_prime($candidate)) {
            $sieve_max = $candidate;
            ++$extra;
        }
        $candidate += 2;
    }

    @primes_odd = @{primes(3, $sieve_max)};

    $have_best = 0;
    ($visited_nodes, $forced_nodes, $terminal_nodes, $factorizations) = (0, 0, 0, 0);

    my $started = clock_gettime(CLOCK_MONOTONIC);
    search_dfs($product_at_depth[0], $lcm_at_depth[0], 3, 0, $target_n, 0);
    my $elapsed = clock_gettime(CLOCK_MONOTONIC) - $started;

    printf STDERR "[%s, %s] sieve=%s nodes=%s forced=%s factorizations=%s terminal=%s time=%.3f s",
      Rmpz_get_str($lower, 10),
      Rmpz_get_str($upper, 10),
      $sieve_limit,
      $visited_nodes,
      $forced_nodes,
      $factorizations,
      $terminal_nodes,
      $elapsed;

    if ($have_best) {
        my $answer = Rmpz_get_str($best, 10);
        print STDERR " FOUND\n";
        print "a($target_n) = $answer\n";
        exit 0;
    }

    print STDERR " none\n";

    # The intervals [lower, upper] are contiguous and disjoint.  Therefore,
    # the first interval containing a solution contains the global minimum.
    Rmpz_add_ui($lower, $upper, 1);
    Rmpz_mul_2exp($upper, $upper, 1);
}
