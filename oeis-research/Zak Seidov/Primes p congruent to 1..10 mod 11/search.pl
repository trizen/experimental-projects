#!/usr/bin/perl

# Primes p such that, starting with p, 10 consecutive primes = {1,2,3,4,5,6,7,8,9,10} modulo 11.
# https://oeis.org/A338374

use 5.014;
use warnings;
use ntheory qw(:all);

# New terms found:
#   1053978912361, 1113788109127, 1188162419291, 1562407603483

my $from = prev_prime(715117260463-1e7);
my @root = $from;

while (@root < 9) {
    $from = next_prime($from);
    push @root, $from;
}

forprimes {

    if ($_ % 11 == 10 and $root[0]%11 == 1) {
        my $ok = 1;
        foreach my $k (2..9) {
            if (($root[$k-1] % 11) != $k) {
                $ok = 0;
                last;
            }
        }
        say $root[0] if $ok;
    }

    push @root, $_;
    shift @root;

} next_prime($from), 1e14;

__END__

715117260463
1053978912361
1113788109127
1188162419291
1562407603483
^C
perl x.pl  5762.19s user 6.53s system 98% cpu 1:37:21.95 total
