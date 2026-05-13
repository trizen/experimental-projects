#!/usr/bin/perl

# a(n) is the largest integer k < 2^(n-1) for which the number of divisors is equal to n, or 0 if no such k exists.
# https://oeis.org/A395952

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

sub prime_signature_numbers_in_range($A, $B, $prime_signature) {

    my $k = scalar(@$prime_signature);

    # The smallest possible number with k distinct prime factors
    $A = vecmax(pn_primorial($k), $A);

    my $max_value = 0;

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
                $max_value = vecmax($max_value, mulint($m, powint($p, $e)));
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

    my $sum_e = vecsum(@$prime_signature);

    unique_permutations(
        $prime_signature,
        sub ($perm) {
            $generate->(1, 2, scalar(@$perm), $perm, $sum_e);
        }
    );

    return $max_value;
}

sub multiplicative_partitions($n) {

    my @results;

    sub ($target, $min_factor, $path) {

        for my $d (divisors($target)) {

            next if $d < $min_factor;
            my $quotient = divint($target, $d);

            if ($quotient == 1) {
                push @results, [sort { $a <=> $b } (@$path, $d)];
            }
            elsif ($quotient >= $d) {
                __SUB__->($quotient, $d, [@$path, $d]);
            }
        }
      }
      ->($n, 2, []);

    @results = sort { scalar(@$a) <=> scalar(@$b) } @results;

    return @results;
}

sub inverse_tau($A, $B, $n) {

    my @signatures = map {
        [map { $_ - 1 } @$_]
    } multiplicative_partitions($n);

    my $max_value = 0;
    foreach my $sig (@signatures) {
        $max_value = vecmax($max_value, prime_signature_numbers_in_range($A, $B, $sig));
    }

    $max_value;
}

foreach my $n(1..50) {

    my $B = subint(powint(2, $n-1), 1);
    my $A = divint($B, 2);

    my $found = 0;

    while (1) {
        my $max_value = inverse_tau($A, $B, $n);
        if ($max_value) {
            say "a($n) = $max_value";
            $found = 1;
            last;
        }
        $B = subint($A, 1);
        $A = divint($B, 2);
        last if ($B <= 0);
    }

    say "a($n) = 0" if !$found;
}

__END__
a(1) = 0
a(2) = 0
a(3) = 0
a(4) = 6
a(5) = 0
a(6) = 28
a(7) = 0
a(8) = 114
a(9) = 225
a(10) = 496
a(11) = 0
a(12) = 2044
a(13) = 0
a(14) = 8128
a(15) = 15376
a(16) = 32766
a(17) = 0
a(18) = 131043
a(19) = 0
a(20) = 524240
a(21) = 1032256
a(22) = 2087936
a(23) = 0
a(24) = 8388588
a(25) = 14776336
a(26) = 33550336
a(27) = 66928761
a(28) = 134217536
a(29) = 0
a(30) = 536870800
a(31) = 0
a(32) = 2147483624
a(33) = 4272844689
a(34) = 8589869056
a(35) = 16649257024
a(36) = 34359738100
a(37) = 0
a(38) = 137438691328
a(39) = 274810802176
