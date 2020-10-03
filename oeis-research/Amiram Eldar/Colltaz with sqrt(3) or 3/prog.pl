#!/usr/bin/perl

# https://oeis.org/draft/A306978

use 5.020;
use warnings;
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

foreach my $k(77676682, 134539960, 402368674, 696922987, 1207106023, 2090768962, 3632578906, 6291811228, 10897736719, 18875433685) {
    say "$k -> ", f($k);
}

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
