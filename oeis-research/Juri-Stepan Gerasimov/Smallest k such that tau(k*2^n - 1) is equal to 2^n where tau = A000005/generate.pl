#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 14 May 2026
# https://github.com/trizen

# Generate all the numbers in a given range [A,B] that have exactly `n` divisors.

use 5.036;
use ntheory 0.74 qw(:all);

sub rootint_ceil($n, $k) {
    rootint($n, $k) + (is_power($n, $k) ? 0 : 1);
}

sub unique_permutations($array, $callback) {
    sub ($items, $current_perm) {

        if (!@$items) {
            $callback->($current_perm);
            return;
        }

        my %level_seen;
        for my $i (0 .. $#$items) {
            my $item = $items->[$i];

            # Skip iterations for duplicate elements in the same level
            next if $level_seen{$item}++;

            my @new_items = @$items;
            splice(@new_items, $i, 1);

            my @new_perm = (@$current_perm, $item);
            __SUB__->(\@new_items, \@new_perm);
        }
    }->($array, []);
}

sub prime_signature_numbers_in_range($A, $B, $prime_signature, $callback) {

    my $k = scalar(@$prime_signature);

    if ($k == 0) {
        $callback->(1) if ($A <= 1 and 1 <= $B);
        return;
    }

    # The smallest possible number with k distinct prime factors
    $A = vecmax(pn_primorial($k), $A);

    my $generate = sub ($m, $lo, $k, $P, $sum_e) {

        my $e  = $P->[$k - 1];
        my $hi = rootint(divint($B, $m), $sum_e);

        if ($lo > $hi) {
            return;
        }

        # Base case
        if ($k == 1) {

            # Tighten the lower bound based on A
            my $lo_tight = vecmax($lo, rootint_ceil(cdivint($A, $m), $e));

            foreach my $p (@{primes($lo_tight, $hi)}) {
                $callback->(mulint($m, powint($p, $e)));
            }

            return;
        }

        for (my $p = $lo ; $p <= $hi ;) {
            my $t = mulint($m, powint($p, $e));
            my $r = next_prime($p);
            __SUB__->($t, $r, $k - 1, $P, $sum_e - $e);
            $p = $r;
        }
    };

    my $sum_e = vecsum(@$prime_signature) || return;

    if ($sum_e > logint($B, 2)) {
        return;
    }

    unique_permutations(
        $prime_signature,
        sub ($perm) {
            $generate->(1, 2, scalar(@$perm), $perm, $sum_e);
        }
    );
}

sub multiplicative_partitions($n, $max_value = $n) {

    my @results;
    my @divs = divisors($n);

    shift(@divs);   # remove divisor '1'

    my $end = $#divs;
    sub ($target, $min_idx, $path) {

        if ($target == 1) {
            push @results, $path;
            return;
        }

        for my $i ($min_idx .. $end) {
            my $d = $divs[$i];

            # Prune branch if the divisor exceeds the remaining target
            last if $d > $target;
            last if $d > $max_value;

            if ($target % $d == 0) {
                __SUB__->(divint($target, $d), $i, [@$path, $d]);
            }
        }
    }->($n, 0, []);

    return @results;
}

sub inverse_tau($A, $B, $n, $callback) {

    my @signatures = map {
        [map { $_ - 1 } @$_]
    } multiplicative_partitions($n, logint($B, 2) + 1);

    foreach my $sig (@signatures) {
        prime_signature_numbers_in_range($A, $B, $sig, $callback);
    }
}

my $n = 15;
my $lo = 1;
my $hi = 2*$lo;
my $min = 9**9**9;

while (1) {

    say "Sieving: [$lo, $hi]";
    my $found = 0;

    inverse_tau($lo, $hi, powint(2,$n), sub($v) {
        if ($v < $min and valuation($v+1, 2) >= $n) {
            my $k = divint($v+1, powint(2, $n));
            say "Upper-bound: a($n) <= $k";
            $min = $v;
            $found = 1;
        }
    });

    last if $found;

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
Sieving: [17592186044415, 35184372088830]
Upper-bound: a(12) <= 8167862431
perl generate.pl  1.05s user 0.01s system 99% cpu 1.058 total

Sieving: [2251799813685247, 4503599627370494]
Upper-bound: a(13) <= 317808279653
perl generate.pl  14.35s user 0.01s system 99% cpu 14.358 total

Sieving: [288230376151711743, 576460752303423486]
Upper-bound: a(14) <= 30964627320559
Upper-bound: a(14) <= 19868058417139
perl generate.pl  239.15s user 0.02s system 99% cpu 3:59.19 total

Sieving: [9223372036854775807, 18446744073709551614]
Upper-bound: a(15) <= 372463979178257
perl generate.pl  515.16s user 0.03s system 99% cpu 8:35.24 total
