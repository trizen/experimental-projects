#!/usr/bin/perl

# Number of k <= 2^(n-1) such that tau(k) = n where tau = A000005.
# https://oeis.org/A393179

use 5.036;
use ntheory 0.74 qw(:all);

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
            $count += prime_count($hi) - $j;
            return;
        }

        if ($k == 2) {
            my $e2 = $P->[0];
            foreach my $p (@{primes($lo, $hi)}) {
                my $t = mulint($m, powint($p, $e));
                my $u = rootint(divint($n, $t), $e2);
                $count += prime_count($u) - ++$j;
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

    my %seen;
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

sub count_prime_signature_numbers_in_range($A, $B, $signature) {
    my $term_1 = count_prime_signature_numbers($A - 1, $signature);
    my $term_2 = count_prime_signature_numbers($B,     $signature);
    $term_2 - $term_1;
}

sub multiplicative_partitions($n, $max_sum = $n) {

    my @results;
    my @divs = divisors($n);

    shift(@divs);    # remove divisor '1'

    my $end = $#divs;
    sub ($target, $min_idx, $curr_sum, $path) {

        if ($target == 1) {
            push @results, $path;
            return;
        }

        for my $i ($min_idx .. $end) {
            my $d = $divs[$i];

            # Prune branch if the divisor exceeds the remaining target
            last if $d > $target;
            last if ($curr_sum + $d > $max_sum);

            if ($target % $d == 0) {
                __SUB__->(divint($target, $d), $i, $curr_sum + $d, [@$path, $d]);
            }
        }
    }->($n, 0, 0, []);

    return @results;
}

sub count_inverse_tau($A, $B, $n) {

    my @signatures = map {
        [map { $_ - 1 } @$_]
    } multiplicative_partitions($n, logint($B, 2) + 1);

    my @counts;
    foreach my $sig (@signatures) {
        push @counts, count_prime_signature_numbers_in_range($A, $B, $sig);
    }

    vecsum(@counts);
}

count_inverse_tau(1,   powint(2, 9),  10) == 13    or die "error";
count_inverse_tau(1,   powint(2, 40), 5040) == 103 or die "error";
count_inverse_tau(1e5, 1e5 + 500, 48) == 10 or die "error";

# Number of k <= 2^(n-1) such that tau(k) = n
# https://oeis.org/A393179
foreach my $n (1 .. 65) {
    say "a($n) = ", count_inverse_tau(1, powint(2, $n - 1), $n);
}

__END__
a(1) = 1
a(2) = 1
a(3) = 1
a(4) = 2
a(5) = 1
a(6) = 5
a(7) = 1
a(8) = 16
a(9) = 5
a(10) = 13
a(11) = 1
a(12) = 211
a(13) = 1
a(14) = 35
a(15) = 19
a(16) = 3134
a(17) = 1
a(18) = 1577
a(19) = 1
a(20) = 8043
a(21) = 46
a(22) = 319
a(23) = 1
a(24) = 615620
a(25) = 19
a(26) = 1045
a(27) = 1565
a(28) = 383778
a(29) = 1
a(30) = 768107
a(31) = 1
a(32) = 167262047
a(33) = 374
a(34) = 12296
a(35) = 83
a(36) = 325122420
a(37) = 1
a(38) = 43460
a(39) = 1167
a(40) = 6200272135
a(41) = 1
a(42) = 409822597
a(43) = 1
a(44) = 1108940842
a(45) = 352281
a(46) = 564349
a(47) = 1
a(48) = 7832178297534
a(49) = 77
a(50) = 20854198211
a(51) = 12959
a(52) = 62955792313
a(53) = 1
a(54) = 1540432298821
a(55) = 535
a(56) = 81973967619694
a(57) = 45036
a(58) = 28193568
a(59) = 1
a(60) = 934568375753531
a(61) = 1
a(62) = 105098920
a(63) = 54930803
