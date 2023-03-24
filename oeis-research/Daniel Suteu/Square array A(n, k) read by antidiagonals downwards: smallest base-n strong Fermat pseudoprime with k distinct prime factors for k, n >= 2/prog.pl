#!/usr/bin/perl

# Square array A(n, k) read by antidiagonals downwards: smallest base-n strong Fermat pseudoprime with k distinct prime factors for k, n >= 2.

# See also:
#   https://oeis.org/A271873

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub strong_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my %seen;

    my $generator = sub ($m, $L, $lo, $j, $k_exp, $congr) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        if ($j == 1) {

            Math::GMPz::Rmpz_invert($v, $m, $L);

            if (Math::GMPz::Rmpz_cmp_ui($v, $hi) > 0) {
                return;
            }

            if (Math::GMPz::Rmpz_fits_ulong_p($L)) {
                $L = Math::GMPz::Rmpz_get_ui($L);
            }

            my $t = Math::GMPz::Rmpz_get_ui($v);
            $t > $hi && return;
            $t += $L while ($t < $lo);

            for (my $p = $t ; $p <= $hi ; $p += $L) {

                if (is_prime_power($p) and Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p) == 1 and gcd($base, $p) == 1) {

                    my $val = valuation($p - 1, 2);
                    $val > $k_exp                                                   or next;
                    powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p) or next;

                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);

                    if ($k == 1 and is_prime($p) and Math::GMPz::Rmpz_cmp_ui($m, 1) == 0) {
                        ## ok
                    }
                    elsif (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_ui_p($u, znorder($base, $p))) {
                            if (!$seen{Math::GMPz::Rmpz_get_str($v, 10)}++) {
                                my $value = Math::GMPz::Rmpz_init_set($v);
                                $B = $value if ($value < $B);
                                #say "Found upper-bound: $value";
                                $callback->($value);
                            }
                        }
                    }
                }
            }

            return;
        }

        my $u   = Math::GMPz::Rmpz_init();
        my $v   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;

            my $val = valuation($p - 1, 2);
            $val > $k_exp                                                   or next;
            powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p) or next;

            my $z = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);

            Math::GMPz::Rmpz_set_ui($u, $p);

            for (Math::GMPz::Rmpz_mul_ui($v, $m, $p) ;
                 Math::GMPz::Rmpz_cmp($v, $B) <= 0 ;
                 Math::GMPz::Rmpz_mul_ui($v, $v, $p)) {
                __SUB__->($v, $lcm, $p + 1, $j - 1, $k_exp, $congr);
                Math::GMPz::Rmpz_mul_ui($u, $u, $p);
                powmod($base, $z, $u) == 1 or last;
            }
        }
    };

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, 0, 1);

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (reverse(0 .. logint($B, 2))) {
        $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, $v, -1);
    }
}

sub T($n, $k) {

    #say "Searching for a($n)";

    my $x = 1;
    my $y = 2*$x;

    #$x = Math::GMPz->new("12428336051357263377401993232370");
    #$y = Math::GMPz->new("17890806687914532842449765082011");

    $x = Math::GMPz->new("$x");
    $y = Math::GMPz->new("$y");

    for (;;) {
        #say "Sieving range: [$x, $y]";
        my @arr;
        strong_fermat_pseudoprimes_in_range($x, $y, $k, $n, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

for my $n(2..6) {
    my @arr;
    foreach my $k(2..6) {
        push @arr, T($n, $k);
    }
    say "@arr";
}

my %strong_psp_2 = qw(
2 2047
3 15841
4 800605
5 293609485
6 10761055201
7 5478598723585
8 713808066913201
9 90614118359482705
10 5993318051893040401
11 24325630440506854886701
12 27146803388402594456683201
13 4365221464536367089854499301
14 2162223198751674481689868383601
15 548097717006566233800428685318301
16 348613808580816298169781820233637261
17 179594694484889004052891417528244514541
);

for my $k (2..1000) {

    say $strong_psp_2{$k} // last;

    foreach my $n (3..$k) {
        say T($n, $k - $n + 2);
    }
}

__END__

Terms:

2047, 15841, 703, 800605, 8911, 341, 293609485, 152551, 4371, 781, 10761055201, 41341321, 129921, 24211, 217, 5478598723585, 12283706701, 9224391, 4382191, 29341, 325, 713808066913201, 1064404682551, 2592053871, 381347461, 3405961, 58825, 65, 90614118359482705, 19142275066201, 201068525791, 9075517561, 557795161, 1611805, 15841, 91, 5993318051893040401, 31475449738947061, 15804698567581, 2459465259031, 333515107081, 299048101, 205465, 1729, 91, 24325630440506854886701, 5405254780334022901, 8211666556476901, 1009614375233101, 17075314684351, 451698887431, 62338081, 63973, 1729, 133, 27146803388402594456683201, 649053318057640906411, 285574887575981641, 97383398181018301, 2805619369385521, 37388680793101, 10761055201, 20821801, 251251, 50997, 91, 4365221464536367089854499301, 512362775244582336338551, 350010251220384686701, 11290262679772872301, 364410024106892401, 5290810955703001, 1387708021141, 130027051, 67976623, 111055, 1729, 85,

-------------------
