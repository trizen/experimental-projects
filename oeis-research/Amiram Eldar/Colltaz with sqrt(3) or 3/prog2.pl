#!/usr/bin/perl

# Numbers with record number of iterations of x -> A306938(x) required to reach 1 (A306944).
# https://oeis.org/A306978

use 5.020;
use warnings;
use Math::AnyNum qw(:overload ceil sqrt floor round);
use experimental qw(signatures);

sub f ($n) {

    my $count = 0;
    my $cons = 0;

    while ($n != 1) {
        ++$count;

        if ($n % 3 == 0) {
            $n = int($n/3);
            $cons = 0;
        }
        else {
            if ($cons) {
                return -1;
            }

            $n = int($n * sqrt(3));
            $cons = 1;
        }
    }

    $count;
}

# Conjecture: sqrt(3) < a(n)/a(n-1) <= 3. - ~~~~

my $prev = 1;
foreach my $k(
 2, 4, 7, 21, 49, 85, 253, 442, 766, 1327, 2299, 3982, 11839, 20506, 35518, 61519, 184557, 553645, 966928, 1674769, 2900785, 8701141, 25877593, 44821306, 77676682, 134539960, 402368674, 696922987, 1207106023, 2090768962, 3632578906,
6291811228, 10897736719, 18875433685

) {
    #say "$k -> ", ceil($k * sqrt(3));
    say "$k -> ", $k/$prev, ' -> ', ($k/$prev) > sqrt(3);
    $prev = $k;
}

__END__

my $prev = 6291811228;

foreach my $n(1..10) {
    my $curr = ceil($prev * sqrt(3));

    say $curr;

    if (f($curr) == -1) {
        $curr = $prev * 3;
        say "$curr -> ", f($curr);
    }
    else {
        say "$curr -> ", f($curr);
    }

    $prev = $curr;
}

__END__

foreach my $k(77676682, 134539960, 402368674, 696922987, 1207106023, 2090768962, 3632578906, 6291811228, 10897736719, 18875433685, 56626301055) {
    say "$k -> ", f($k);
}


__END__
# 6291811228 -- 55
# 10897736719 -- 57
# 18875433685 -- 59

my $record = 59;

foreach my $k(18875433685 * 1.732 ..1e11) {
    if (f($k) > $record) {
        $record = f($k);
        say "New record: $record with $k";
    }
}
