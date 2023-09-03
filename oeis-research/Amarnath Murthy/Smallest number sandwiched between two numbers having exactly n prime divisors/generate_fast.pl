#!/usr/bin/perl

# Smallest number sandwiched between two numbers having exactly n prime divisors.
# https://oeis.org/A088075

# Known terms:
#   3, 11, 131, 1429, 77141, 1456729, 117048931, 10326137821, 1110819807371, 140734085123059, 11639258217451019

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub generate ($A, $B, $n) {

    $A = vecmax($A, pn_primorial($n));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $j) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);
        Math::GMPz::Rmpz_fits_ulong_p($u) or die "Too large!";

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        my @lst;
        my $v = Math::GMPz::Rmpz_init();

        foreach my $q (@{primes($lo, $hi)}) {

            #$q % 4 == 3 and next;

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        if (is_omega_prime($n, $v - 2)) {
                            my $t = Math::GMPz::Rmpz_init_set($v);
                            Math::GMPz::Rmpz_sub_ui($t, $t, 1);
                            say("[1] Found upper-bound: ", $t);
                            $B = $t if ($t < $B);
                            push @lst, $t;
                        }

                        # elsif (is_omega_prime($n, $v+2)) {
                        #     my $t = Math::GMPz::Rmpz_init_set($v);
                        #     Math::GMPz::Rmpz_add_ui($t, $t, 1);
                        #     say("[2] Found upper-bound: ", $t);
                        #     $B = $t if ($t < $B);
                        #     push @lst, $t;
                        # }
                    }
                }
                else {
                    push @lst, __SUB__->($v, $q + 1, $j - 1);
                }
                Math::GMPz::Rmpz_mul_ui($v, $v, $q);
            }
        }

        return @lst;
      }
      ->(Math::GMPz->new(1), 2, $n);

    return sort { $a <=> $b } @values;
}

sub a ($n) {

    if ($n == 0) {
        return 1;
    }

    my $x = Math::GMPz->new(pn_primorial($n));

    #my $y = 3*$x;
    my $y = (4 * $x) / 3;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v = generate($x, $y, $n);
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;

        #$y = 3*$x;
        $y = (4 * $x) / 3;
    }
}

foreach my $n (9) {
    say "a($n) = ", a($n);
}

__END__
Sieving range: [9932483583, 19864967166]
[1] Found upper-bound: 14245339109
[2] Found upper-bound: 13761033859
[2] Found upper-bound: 13129874759
[1] Found upper-bound: 10326137821
[2] Found upper-bound: 10326137821
a(8) = 10326137821
perl generate_fast.pl  24.27s user 0.50s system 85% cpu 29.108 total
