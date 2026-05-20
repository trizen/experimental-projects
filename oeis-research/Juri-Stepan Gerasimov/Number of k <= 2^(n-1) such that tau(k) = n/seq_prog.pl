#!/usr/bin/perl

# Author: Daniel Suteu, 19 May 2026
# Number of k <= 2^(n-1) such that tau(k) = n where tau = A000005.
# https://oeis.org/A393179

use 5.036;
use ntheory 0.74 qw(:all);

prime_precalc(1e7);

sub unique_permutations($array, $callback) {
    sub ($items, $current_perm) {

        if (!@$items) {
            $callback->($current_perm);
            return;
        }

        my %level_seen;
        for my $i (0 .. $#$items) {
            my $item = $items->[$i];
            next if $level_seen{$item}++;

            my @new_items = @$items;
            splice(@new_items, $i, 1);

            my @new_perm = (@$current_perm, $item);
            __SUB__->(\@new_items, \@new_perm);
        }
    }->($array, []);
}

sub count_prime_signature_numbers($n, $prime_signature) {

    my $k = scalar(@$prime_signature);

    if ($k == 0) {
        return 1 if (1 <= $n);
        return 0;
    }

    $n >= 1 || return 0;

    my $count = 0;

    my $generate = sub ($m, $lo, $k, $P, $sum_e, $j = 0) {

        my $e  = $P->[$k - 1];
        my $hi = rootint(divint($n, $m), $sum_e);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {
            $count = addint($count, prime_count($hi) - $j);
            return;
        }

        if ($k == 2) {
            my $e2 = $P->[0];
            foreach my $p (@{primes($lo, $hi)}) {
                my $t = mulint($m, powint($p, $e));
                my $u = ($e2 == 1) ? divint($n, $t) : rootint(divint($n, $t), $e2);
                if ($u > 1e11) {
                    require Math::Sidef;
                    $Sidef::Types::Number::Number::USE_PRIMECOUNT = 1;
                    say "Computing pi($u)";
                    $count = addint($count, Math::Sidef::prime_count($u) - ++$j);
                }
                else {
                    $count = addint($count, prime_count($u) - ++$j);
                }
            }
            return;
        }

        for (my $p = $lo ; $p <= $hi ;) {
            my $t = mulint($m, powint($p, $e));
            my $r = next_prime($p);
            __SUB__->($t, $r, $k - 1, $P, $sum_e - $e, ++$j);
            $p = $r;
        }
    };

    my $sum_e = vecsum(@$prime_signature) || return 0;

    if ($sum_e > logint($n, 2)) {
        return 0;
    }

    unique_permutations(
        $prime_signature,
        sub ($perm) {
            $generate->(1, 2, scalar(@$perm), $perm, $sum_e);
        }
    );

    return $count;
}

sub multiplicative_partitions($n, $max_value = $n) {

    my @results;
    my @divs = divisors($n);

    shift(@divs);    # remove divisor '1'

    my $end = $#divs;
    my @path;

    sub ($target, $min_idx) {

        if ($target == 1) {
            push @results, [@path];
            return;
        }

        for my $i ($min_idx .. $end) {
            my $d = $divs[$i];

            last if $d > $target;
            last if $d > $max_value;

            if ($target % $d == 0) {
                push @path, $d;
                __SUB__->(divint($target, $d), $i);
                pop @path;
            }
        }
    }->($n, 0);

    return @results;
}

sub count_inverse_tau($upto, $n) {

    my @signatures = map {
        [map { $_ - 1 } @$_]
    } multiplicative_partitions($n, logint($upto, 2) + 1);

    my @counts;
    foreach my $sig (@signatures) {
        push @counts, count_prime_signature_numbers($upto, $sig);
    }

    vecsum(@counts);
}

sub a($n) {
    count_inverse_tau(powint(2, $n - 1), $n);
}

foreach my $n (1..100) {
    say "a($n) = ", a($n);
}
