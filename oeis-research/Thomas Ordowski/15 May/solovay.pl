#!/usr/bin/perl

use 5.014;
use ntheory qw(:all);

# a(1)  = 561
# a(2)  = 1729
# a(3)  = 1729
# a(4)  = 399001
# a(5)  = 399001
# a(6)  = 1857241
# a(7)  = 1857241
# a(8)  = 6189121
# a(9)  = 14469841
# a(10) = 14469841
# a(11) = 14469841
# a(12) = 86566959361
# a(13) = 311963097601
# a(14) = 369838909441
# a(15) = 6389476833601
# a(16) = 6389476833601
#
# Some upper-bounds for the next few terms:
# a(17) <= 1606205228509922041
# a(18) <= 1606205228509922041
# a(19) <= 1606205228509922041
# a(20) <= 1606205228509922041

my $N = 3;
my $P = nth_prime($N);

sub isok {
    my ($k) = @_;
    vecall { powmod($_, ($k-1)>>1, $k) == (kronecker($_, $k) % $k) } 2..$P;
}

sub foo {
    my ($n) = @_;

    my $P = nth_prime($n);

    for(my $k = 3; ; $k += 2) {
        next if is_prime($k);

        while (vecall { powmod($_, ($k-1)>>1, $k) == (kronecker($_, $k) % $k) } 2..$P) {
            #return $k;
            $P = next_prime($P);
            say "a($n) = $k";
            ++$n;
        }
    }
}

foo(1);
