#!/usr/bin/perl

# Smallest squarefree palindrome with exactly n distinct prime factors.
# https://oeis.org/A046399

# Known terms:
#   1, 2, 6, 66, 858, 6006, 222222, 22444422, 244868442, 6434774346, 438024420834, 50146955964105, 2415957997595142, 495677121121776594, 22181673755737618122, 8789941164994611499878

# Corrected term:
#   a(15) = 5521159517777159511255

# New term found by Michael S. Branicky:
#   a(16) = 477552751050050157255774

# Lower-bounds:
#   a(17) > 252020044615415406440021243
#   a(17) > 252020044615424516440020252

# Timings:
#   a(12) is found in 0.2 seconds
#   a(13) is found in 6.5 seconds
#   a(14) is found in 9.7 seconds
#   a(15) is found in 17 minutes

# While searching for a(17), it took 9 hours to check the range [63005011153853239757078527, 126010022307706479514157054].
# While searching for a(17), it took 33 hours to check the range [126010022307707703220010621, 252020044615415406440021243]

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub squarefree_omega_palindromes ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    sub ($m, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            Math::GMPz::Rmpz_cdiv_q($u, $A, $m);

            if (Math::GMPz::Rmpz_fits_ulong_p($u)) {
                $lo = vecmax($lo, Math::GMPz::Rmpz_get_ui($u));
            }
            elsif (Math::GMPz::Rmpz_cmp_ui($u, $lo) > 0) {
                if (Math::GMPz::Rmpz_cmp_ui($u, $hi) > 0) {
                    return;
                }
                $lo = Math::GMPz::Rmpz_get_ui($u);
            }

            if ($lo > $hi) {
                return;
            }

            foreach my $p (@{primes($lo, $hi)}) {
                Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                my $s = Math::GMPz::Rmpz_get_str($v, 10);
                if ($s eq reverse($s)) {
                    my $r = Math::GMPz::Rmpz_init_set($v);
                    say("Found upper-bound: ", $r);
                    $B = $r if ($r < $B);
                    $callback->($r);
                }
            }

            return;
        }

        my $z = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {
            if ($p == 5 and Math::GMPz::Rmpz_even_p($m)) {
                ## last digit can't be zero
            }
            else {
                Math::GMPz::Rmpz_mul_ui($z, $m, $p);
                __SUB__->($z, $p+1, $k-1);
            }
        }
    }->(Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    #my $x = Math::GMPz->new(pn_primorial($n));
    my $x = Math::GMPz->new("252020044615424516440020252");
    my $y = (5*$x)>>2;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v;
        squarefree_omega_palindromes($x, $y, $n, sub ($k) {
            push @v, $k;
        });
        @v = sort { $a <=> $b } @v;
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y+1;
        $y = (5*$x)>>2;
    }
}

foreach my $n (17) {
    say "a($n) = ", a($n);
}
