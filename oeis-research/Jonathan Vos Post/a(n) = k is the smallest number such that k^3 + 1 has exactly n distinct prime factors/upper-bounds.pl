#!/usr/bin/perl

# a(n) = k is the smallest number such that k^3 + 1 has exactly n distinct prime factors.
# https://oeis.org/A219108

# Known terms:
#   0, 1, 3, 5, 17, 59, 101, 563, 2617, 9299, 22109, 132989, 364979, 1970869, 23515229, 109258049, 831731339

# Upper-bounds:
#   a(17) <= 4015430429 < 10652511869
#   a(18) <= 62754514679 < 79622275589 < 90298969529

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

use ntheory      qw(:all);
use experimental qw(signatures);

use Math::GMPz;
use Math::Prime::Util::GMP;

use constant {
              TRIAL_LIMIT        => 1e3,
              HAS_NEW_PRIME_UTIL => defined(&Math::Prime::Util::is_omega_prime),
             };

my @small_primes = @{primes(TRIAL_LIMIT)};

sub mpz_is_omega_prime ($n, $k) {

    state $z = Math::GMPz::Rmpz_init();
    state $t = Math::GMPz::Rmpz_init();

    if ($n == 0) {
        return 0;
    }

    Math::GMPz::Rmpz_set_str($z, "$n", 10);
    Math::GMPz::Rmpz_root($t, $z, $k);

    my $trial_limit = Math::GMPz::Rmpz_get_ui($t);

    if ($trial_limit > TRIAL_LIMIT or !Math::GMPz::Rmpz_fits_ulong_p($t)) {
        $trial_limit = TRIAL_LIMIT;
    }

    foreach my $p (@small_primes) {

        last if ($p > $trial_limit);

        if (Math::GMPz::Rmpz_divisible_ui_p($z, $p)) {
            --$k;
            Math::GMPz::Rmpz_set_ui($t, $p);
            Math::GMPz::Rmpz_remove($z, $z, $t);
        }

        ($k > 0) or last;

        if (HAS_NEW_PRIME_UTIL and Math::GMPz::Rmpz_fits_ulong_p($z)) {
            return Math::Prime::Util::is_omega_prime($k, Math::GMPz::Rmpz_get_ui($z));
        }
    }

    if (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0) {
        return ($k == 0);
    }

    if ($k == 0) {
        return (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0);
    }

    if ($k == 1) {

        if (Math::GMPz::Rmpz_fits_ulong_p($z)) {
            return is_prime_power(Math::GMPz::Rmpz_get_ui($z));
        }

        return Math::Prime::Util::GMP::is_prime_power(Math::GMPz::Rmpz_get_str($z, 10));
    }

    Math::GMPz::Rmpz_ui_pow_ui($t, next_prime($trial_limit), $k);

    if (Math::GMPz::Rmpz_cmp($z, $t) < 0) {
        return 0;
    }

    (HAS_NEW_PRIME_UTIL and Math::GMPz::Rmpz_fits_ulong_p($z))
      ? Math::Prime::Util::is_omega_prime($k, Math::GMPz::Rmpz_get_ui($z))
      : (factor_exp(Math::GMPz::Rmpz_get_str($z, 10)) == $k);
}

sub squarefree_generate_native ($A, $B, $j, $n) {

    $A = vecmax($A, pn_primorial($j));

    my $u = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $k) {

        my $hi = rootint(divint($B, $m), $k);

        if ($lo > $hi) {
            return;
        }

        my @list;

        if ($k == 1) {

            $lo = vecmax(cdivint($A, $m), $lo);

            if ($lo > $hi) {
                return;
            }

            foreach my $p (@{primes($lo, $hi)}) {

                #$p % 4 == 3 and next;
                Math::GMPz::Rmpz_set_ui($u, $m * $p - 1);
                Math::GMPz::Rmpz_pow_ui($u, $u, 3);
                Math::GMPz::Rmpz_add_ui($u, $u, 1);

                if (mpz_is_omega_prime($u, $n)) {

                    #say "Candidate: k = $v with k^2 - 1 = $u";

                    my $t = $m * $p;
                    my $w = $t - 1;

                    say("Found upper-bound: ", $w);
                    $B = $t if ($t < $B);
                    push @list, $w;
                }
            }

            return @list;
        }

        foreach my $p ((($lo <= 4 and $hi >= 4) ? (4) : ()), (($lo <= 8 and $hi >= 8) ? (8) : ()), @{primes($lo, $hi)}) {

            #$p % 4 == 3 and next;
            push @list, __SUB__->($m * $p, $p + 1, $k - 1);
        }

        return @list;
      }
      ->(1, 2, $j);

    return sort { $a <=> $b } @values;
}

sub generate_native ($A, $B, $k, $n) {

    $A = vecmax($A, pn_primorial($k));

    my $u = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $j) {

        my $hi = rootint(divint($B, $m), $j);

        if ($lo > $hi) {
            return;
        }

        my @lst;

        foreach my $q (@{primes($lo, $hi)}) {

            #$q % 4 == 3 and next;

            my $v = $m * $q;

            while ($v <= $B) {
                if ($j == 1) {
                    if ($v >= $A) {

                        Math::GMPz::Rmpz_set_ui($u, $v - 1);
                        Math::GMPz::Rmpz_pow_ui($u, $u, 3);
                        Math::GMPz::Rmpz_add_ui($u, $u, 1);

                        if (mpz_is_omega_prime($u, $n)) {

                            my $t = $v;
                            my $w = $v - 1;

                            say("Found upper-bound: ", $w);
                            $B = $t if ($t < $B);
                            push @lst, $w;
                        }
                    }
                }
                else {
                    push @lst, __SUB__->($v, $q + 1, $j - 1);
                }
                $v *= $q;
            }
        }

        return @lst;
      }
      ->(1, 2, $k);

    return sort { $a <=> $b } @values;
}

sub a ($n, $j) {

    if ($n == 0) {
        return 1;
    }

    my $x = pn_primorial($j);
    #$x = 522763263;

    #my $y = (4 * $x) / 3;
    my $y = 2 * $x;

    #my $y = divint(4*$x, 3);

    while (1) {
        say("Sieving range: [$x, $y]");

        my @v = generate_native($x, $y, $j, $n);

        #my @v = squarefree_generate_native($x, $y, $j, $n);

        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;

        #$y = (4 * $x) / 3;
        $y = 2 * $x;

        #$y = divint(4*$x, 3);
    }
}

my $j = 8;
say "Searching with j = $j";

foreach my $n (18) {
    say "a($n) <= ", a($n, $j);
}

__END__
Sieving range: [1241560447, 2483120894]
Sieving range: [2483120895, 4966241790]
Found upper-bound: 4015430429
a(17) <= 4015430429
perl upper-bounds.pl  69.71s user 0.14s system 70% cpu 1:39.29 total
