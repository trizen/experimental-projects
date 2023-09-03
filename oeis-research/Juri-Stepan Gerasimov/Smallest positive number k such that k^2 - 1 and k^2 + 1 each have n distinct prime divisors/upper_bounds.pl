#!/usr/bin/perl

# a(n) is the smallest positive number k such that k^2 - 1 and k^2 + 1 each have n distinct prime divisors.
# https://oeis.org/A365326

# Known terms:
#   2, 5, 13, 83, 463, 4217, 169333, 2273237, 23239523, 512974197, 5572561567

# a(n) >= max(A219017(n), A180278(n)).

# Lower-bounds:
#   a(11) > sqrt(14632489711031894527)
#   a(12) > sqrt(6575140476955311459338)

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub squarefree_generate ($A, $B, $n) {

    $A = vecmax($A, pn_primorial($n));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);
        Math::GMPz::Rmpz_fits_ulong_p($u) or die "Too large!";

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        my @list;

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
                $p % 4 == 3 and next;
                Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                if (Math::GMPz::Rmpz_perfect_square_p($u)) {
                    my $t = Math::GMPz::Rmpz_init_set($v);
                    my $w = sqrtint($u);
                    if (    is_omega_prime($n, mulint($w, $w) - 1)
                        and is_omega_prime($n, mulint($w, $w) + 1)) {
                        say("Found upper-bound: ", $w);
                        $B = $t if ($t < $B);
                        push @list, $w;
                    }
                }
            }

            return @list;
        }

        my $z = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {
            if ($p % 4 == 3) {
                ## p can't be congruent to 3 mod 4.
            }
            else {
                Math::GMPz::Rmpz_mul_ui($z, $m, $p);
                push @list, __SUB__->($z, $p + 1, $k - 1);
            }
        }

        return @list;
      }
      ->(Math::GMPz->new(1), 2, $n);

    return sort { $a <=> $b } @values;
}

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

            $q % 4 == 3 and next;

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_perfect_square_p($u)) {
                            my $t = Math::GMPz::Rmpz_init_set($v);
                            my $w = sqrtint($v - 1);
                            if (    is_omega_prime($n, mulint($w, $w) - 1)
                                and is_omega_prime($n, mulint($w, $w) + 1)) {
                                say("Found upper-bound: ", $w);
                                $B = $t if ($t < $B);
                                push @lst, $w;
                            }
                        }
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

my @lower_bounds = (0, 2, 4, 13, 47, 447, 2163, 24263, 241727, 2923783, 16485763, 169053487, 4535472963);

sub a ($n) {

    if ($n == 0) {
        return 1;
    }

    #my $x = Math::GMPz->new(pn_primorial($n));
    #my $x = Math::GMPz->new($lower_bounds[$n])**2 - 1;
    my $x = Math::GMPz->new("6575140476955311459338");
    my $y = (4 * $x)/3;
    #my $y = 2 * $x;

    while (1) {
        say("Sieving range: [$x, $y]");

        #my @v = generate($x, $y, $n);
        my @v = squarefree_generate($x, $y, $n);
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;
        $y = (4 * $x)/3;
        #$y = 2 * $x;
    }
}

foreach my $n (12) {
    say "a($n) = ", a($n);
}

__END__
Sieving range: [3739644321855, 7479288643710]
Found upper-bound: 2450053
Found upper-bound: 2273237
a(8) = 2273237
perl upper_bounds.pl  0.79s user 0.01s system 49% cpu 1.617 total

Sieving range: [273552224994847, 547104449989694]
Found upper-bound: 23239523
a(9) = 23239523
perl upper_bounds.pl  3.44s user 0.01s system 42% cpu 8.086 total

Sieving range: [203146360576463541, 270861814101951388]
Found upper-bound: 512974197
a(10) = 512974197
perl upper_bounds.pl  146.34s user 0.39s system 44% cpu 5:32.65 total
