#!/usr/bin/perl

# a(n) is the smallest positive number k such that k^2 - 1 and k^2 + 1 each have n distinct prime divisors.
# https://oeis.org/A365326

# Known terms:
#   2, 5, 13, 83, 463, 4217, 169333, 2273237, 23239523, 512974197, 5572561567

# a(n) >= max(A219017(n), A180278(n)).

# Try to find upper-bounds, by generating k-1 as a product of j primes.

# Conjectured lower-bounds:
#   a(11) > sqrt(14632489711031894527)
#   a(12) > sqrt(6575140476955311459338)

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
                Math::GMPz::Rmpz_set_ui($u, $m * $p + 1);
                Math::GMPz::Rmpz_mul_ui($u, $u, $u);
                Math::GMPz::Rmpz_sub_ui($u, $u, 1);

                if (mpz_is_omega_prime($u, $n) and mpz_is_omega_prime($u + 2, $n)) {

                    #if (is_omega_prime($n, $u) and is_omega_prime($n, $u+2)) {
                    #if (is_omega_prime($n, $u+2) and is_omega_prime($n, $u)) {
                    #if (mpz_is_omega_prime($u+2, $n) and mpz_is_omega_prime($u, $n)) {

                    #say "Candidate: k = $v with k^2 - 1 = $u";

                    my $t = $m * $p;
                    my $w = $t + 1;

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

sub squarefree_generate ($A, $B, $j, $n) {

    $A = vecmax($A, pn_primorial($j));
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

                #$p % 4 == 3 and next;
                Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                Math::GMPz::Rmpz_add_ui($u, $v, 1);
                Math::GMPz::Rmpz_mul_ui($u, $u, $u);
                Math::GMPz::Rmpz_sub_ui($u, $u, 1);

                if (mpz_is_omega_prime($u, $n) and mpz_is_omega_prime($u + 2, $n)) {

                    #if (is_omega_prime($n, $u) and is_omega_prime($n, $u+2)) {
                    #if (is_omega_prime($n, $u+2) and is_omega_prime($n, $u)) {
                    #if (mpz_is_omega_prime($u+2, $n) and mpz_is_omega_prime($u, $n)) {

                    #say "Candidate: k = $v with k^2 - 1 = $u";

                    my $t = Math::GMPz::Rmpz_init_set($v);
                    my $w = $v + 1;

                    say("Found upper-bound: ", $w);
                    $B = $t if ($t < $B);
                    push @list, $w;
                }
            }

            return @list;
        }

        my $z = Math::GMPz::Rmpz_init();

        foreach my $p ((($lo <= 4 and $hi >= 4) ? (4) : ()), (($lo <= 8 and $hi >= 8) ? (8) : ()), @{primes($lo, $hi)}) {

            #$p % 4 == 3 and next;
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);
            push @list, __SUB__->($z, $p + 1, $k - 1);
        }

        return @list;
      }
      ->(Math::GMPz->new(1), 2, $j);

    return sort { $a <=> $b } @values;
}

sub generate ($A, $B, $k, $n) {

    $A = vecmax($A, pn_primorial($k));
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

                        Math::GMPz::Rmpz_add_ui($u, $v, 1);
                        Math::GMPz::Rmpz_mul_ui($u, $u, $u);
                        Math::GMPz::Rmpz_sub_ui($u, $u, 1);

                        if (mpz_is_omega_prime($u, $n) and mpz_is_omega_prime($u + 2, $n)) {

                            #if (is_omega_prime($n, $u) and is_omega_prime($n, $u+2)) {

                            my $t = Math::GMPz::Rmpz_init_set($v);
                            my $w = $v + 1;

                            say("Found upper-bound: ", $w);
                            $B = $t if ($t < $B);
                            push @lst, $w;
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
      ->(Math::GMPz->new(1), 2, $k);

    return sort { $a <=> $b } @values;
}

my @lower_bounds = (0, 2, 4, 13, 47, 447, 2163, 24263, 241727, 2923783, 16485763, 169053487, 4535472963);

# Conjectured lower-bounds:
#   j =  6: a(12) > 19112445738.
#   j =  7: a(12) > 107386252058.
#   j =  7: a(12) > 603366376455. (with p != 3 mod 4)
#   j =  8: a(12) > 107386252058.
#   j =  9: a(12) > 120809533565.
#   j = 10: a(12) > 254545190066.

sub a ($n, $j) {

    if ($n == 0) {
        return 1;
    }

    #my $x = Math::GMPz->new(pn_primorial($n));
    #my $x = Math::GMPz->new($lower_bounds[$n])**2 - 1;
    #my $x = Math::GMPz->new("6575140476955311459338");
    #my $x = Math::GMPz->new($lower_bounds[$n]) - 1;
    my $x = $lower_bounds[$n] - 1;

    #$x = Math::GMPz->new("81087239914");
    #$x = Math::GMPz->new("107386252058");
    $x = 107386252058;

    #my $y = (4 * $x) / 3;
    #my $y = 2 * $x;
    my $y = divint(4*$x, 3);

    while (1) {
        say("Sieving range: [$x, $y]");

        #my @v = generate($x, $y, $j, $n);
        #my @v = squarefree_generate($x, $y, $j, $n);
        my @v = squarefree_generate_native($x, $y, $j, $n);

        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;

        #$y = (4 * $x) / 3;
        #$y = 2 * $x;
        $y = divint(4*$x, 3);
    }
}

my $j = 8;
say "Searching with j = $j";

foreach my $n (12) {
    say "a($n) = ", a($n, $j);
}

__END__
Sieving range: [4002674175, 5336898900]
Sieving range: [5336898901, 7115865201]
Found upper-bound: 5572561567
a(11) = 5572561567
perl upper_bounds_2.pl  366.73s user 0.65s system 79% cpu 7:40.70 total
