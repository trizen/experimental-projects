#!/usr/bin/perl

# a(n) is the least k for which A237196(k) = n.
# https://oeis.org/A372648

# Known terms:
#   4, 10, 43, 1, 2, 26, 3, 28, 13, 2311675, 8396, 12918370, 37697697

# New terms:
#   a(14) = 4096146353

# a(n) > a(14), for n >= 15.

use 5.036;
use ntheory qw(:all);
use Test::More;

plan tests => 5;

my @P = (undef, @{primes(100)});

sub a($n, $pn = nth_prime($n)) {

    return undef if ($n <= 0);

    my $t = 1;

    for(my $j = 1; ; ++$j) {
        if ($j != $n) {
            $t *= $P[$j];
        }
        if (!is_prime($t+$pn)) {
            if ($j >= $n) {
                return $j-1;
            }
            else {
                return $j;
            }
        }
    }

    return undef;
}

is(a(2311675), 10);
is(a(8396), 11);
is(a(12918370), 12);
is(a(37697697), 13);
is(a(4096146353), 14);

my @table;

my $k = 4096146353-100;
my $p = nth_prime($k);

forprimes {
    my $v = a($k, $_);
    if ($v >= 14 and !$table[$v]) {
        $table[$v] = $k;
        say "a($v) = $k";
    }
    ++$k;
} $p, 1e12;

__END__
a(4) = 1
a(5) = 2
a(7) = 3
a(1) = 4
a(2) = 10
a(9) = 13
a(6) = 26
a(8) = 28
a(3) = 43
a(11) = 8396
a(10) = 2311675
a(12) = 12918370
a(13) = 37697697
a(14) = 4096146353
