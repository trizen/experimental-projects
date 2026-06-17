#!/usr/bin/perl

# a(n) is the smallest integer k such that the iterated multiplicative-order chain k -> ord_k(2) -> ord_{ord_k(2)}(2) -> ... reaches an even number in exactly n steps.
# https://oeis.org/A396944

# Known terms:
#   3, 7, 47, 1439, 2879, 214559, 429119, 858239, 164255999

use 5.036;
use ntheory qw(:all);

my @table;

for (my $k = 1; ; $k += 2) {

    my $n = 1;
    my $z = znorder(2, $k);

    while (1) {
        last if ($z % 2 == 0);
        last if ($z == 1);
        $z = znorder(2, $z);
        ++$n;
    }

    if (!$table[$n] and $z % 2 == 0) {
        say "a($n) = $k";
        $table[$n] = $k;
    }
}

__END__
a(1) = 3
a(2) = 7
a(3) = 47
a(4) = 1439
a(5) = 2879
a(6) = 214559
a(7) = 429119
a(8) = 858239
a(9) = 164255999
