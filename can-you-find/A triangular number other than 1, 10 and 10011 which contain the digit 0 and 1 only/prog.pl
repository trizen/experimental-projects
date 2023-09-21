#!/usr/bin/perl

# A triangular number other than 1, 10 and 10011 which contain the digit 0 and 1 only.
# Problem: CYF 34.

# The next term (if it exists) is greater than 10^31.

use 5.036;
use Math::Prime::Util::GMP   qw(is_polygonal);
use Algorithm::Combinatorics qw(variations_with_repetition);

my @data = ('0', '1');

foreach my $k (31 .. 1000) {
    say "Testing: k = $k";
    my $iter = variations_with_repetition(\@data, $k);
    while (my $arr = $iter->next) {
        if (is_polygonal(join('', '1', @$arr), 3)) {
            die "Found new term: ", join('', '1', @$arr), "\n";
        }
    }
}

__END__
for k in (1..1000) {
    say "Testing: k = #{k}"
    [0,1].variations_with_repetition(k, {|*a|
        var n = Num('1' + a.join)
        if (n.is_polygonal(3)) {
            say n
        }
    })
}

__END__
Testing: k = 28
Testing: k = 29
Testing: k = 30
Testing: k = 31
^C
perl x.sf  9139.72s user 11.58s system 96% cpu 2:37:47.16 total
