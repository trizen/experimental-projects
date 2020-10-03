#!/usr/bin/perl

# a(n) is the smallest Fermat pseudoprime to base 2 of the form p * (n*(p-1) + 1), where p is prime.

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime);

my $n = 2;
my $count = 1;
my $from = 1e6; #sqrtint(~0);

forprimes {

    my $p = $_;
    my $q = ($_-1)*$n + 1;

    if (is_prime($q) and is_pseudoprime(mulint($p,$q),2)) {

        my $t = mulint($p, $q);
        if ($t > ~0) {
            say $t;
            warn "$t\n";
        }

        ++$n;
        #++$count;
        #my $r = nth_prime($count);

        #$n = $r; #($r+1) * ($r-1);
        #$n = $r*$r;
        #++$n;
        #$n = $count*($count + 1) / 2;
        #$n = next_prime($n);
        #$n *= 11;
        #$n <<= 1;
    }
} $from, $from+1e9;
