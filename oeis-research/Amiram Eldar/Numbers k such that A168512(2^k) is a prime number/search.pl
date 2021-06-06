#!/usr/bin/perl

# Numbers k such that 1 + Sum_{i=1..k} floor(k/i)*(2^i) is a prime number.
# Equivalently, numbers k such that A168512(2^k) is a prime number.
# https://oeis.org/A344783

# Known terms:
#   1, 3, 4, 7, 18, 25, 26, 30, 40, 50, 95, 150, 348, 694, 1052, 1222, 1808, 2567, 4917, 5399, 7438, 10720, 12152, 30412, 38313, 53620

# Next term is > 60000.

use 5.020;
use Math::GMPz;
use experimental qw(signatures);
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::Sidef;

my $ONE = Math::GMPz->new(1);

sub f($n) {

    my $sum = Math::GMPz::Rmpz_init_set_ui(0);
    my $s = sqrtint($n);

    my $r = Math::GMPz::Rmpz_init_set_ui(1);

    foreach my $k (1..$s) {
        Math::GMPz::Rmpz_mul_2exp($r, $r, 1);
        my $t = divint($n, $k);
        $sum += $t * $r;
        $sum += $ONE<<($t+1);
    }

    $sum -= ($ONE<<($s+1))*$s;
    $sum;
}

#~ foreach my $n(10720, 12152, 30412, 38313, 53620) {
    #~ if (is_prob_prime(f($n)+1)) {
        #~ say "OK: $n";
    #~ }
    #~ else {
        #~ die "ERROR for n = $n";
    #~ }
#~ }

my $from = 60006;       # where to start searching from

foreach my $k($from .. 1e6) {

    my $t = f($k)+1;

    say "Testing: k = $k (digits: ", length("$t"), ")";

    #if (Math::Prime::Util::GMP::is_prob_prime($t)) {
    if (Math::Sidef::is_prob_prime($t)) {
        die "Found new term: $k\n";
    }
}
