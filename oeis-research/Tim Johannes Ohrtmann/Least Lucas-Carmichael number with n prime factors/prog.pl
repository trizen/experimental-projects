#!/usr/bin/perl

# Least Lucas-Carmichael number with n prime factors.
# https://oeis.org/A216928

# New terms found:
#   a(15) = 6414735508880546179805759
#   a(16) = 466807799396932243821123839
#   a(17) = 41222773167337486494297521279
#   a(18) = 5670586073047883755094926472159
#   a(19) = 247499293142007885087237709213919
#   a(20) = 202003815733964076599064812732611679
#   a(21) = 17988631465107219093106511654427868799
#   a(22) = 6260401580525839547593293275046894535199
#   a(23) = 521027978053852870937320124850878216361599
#   a(24) = 257685984879302905034127894788339525937551999
#   a(25) = 39355410745046203120019553518734961968898942399
#   a(26) = 1422206796849165887380738983840035626943341276799
#   a(27) = 438252156495754541448512765942687553061536148703999
#   a(28) = 333791863958043189671786617765781459382301668208175999

# Upper-bounds:
#   a(30) <= 19506658949536084552467811979883978355065673257930001583999
#   a(32) <= 1212800509317905538106330365884285329525761794519636131919923199

# New terms (24 February 2023):
#   a(29) = 46521156947634673750957825164223546441200487134525859199
#   a(30) = 19074090435451829746746984053080361421706952409259779667199
#   a(31) = 3532037553146436562783521728890404729368163364907619947395199
#   a(32) = 765881596754684241380045525579098611589814471468465029532759999
#   a(33) = 275114850916952422937505205424521323097783162400484048783681267839
#   a(34) = 99955119012110217537288587166217937093673720603174918405034884380159
#   a(35) = 27216112313596458952695010988196606980991999599340735144892271012553599

# It took 1 hour and 1 minute to find a(34).
# It took 2 hours and 20 minutes to find a(35).

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub lucas_carmichael_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k + 1) >> 1);

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    sub ($m, $L, $lo, $k) {

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

            Math::GMPz::Rmpz_invert($v, $m, $L);
            Math::GMPz::Rmpz_sub($v, $L, $v);

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
                if (is_prime($p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_add_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $p + 1)) {
                        my $w = Math::GMPz::Rmpz_init_set($v);
                        say "Found upper-bound: $w";
                        $B = $w if ($w < $B);
                        $callback->($w);
                    }
                }
            }

            return;
        }

        my $z   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p + 1) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p + 1);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p + 1, $k - 1);
        }
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), 3, $k);
}


sub a($n) {

    if ($n == 0) {
        return 1;
    }

    my $x = (Math::GMPz->new(pn_primorial($n+1)))>>1;
    my $y = 2*$x;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v;
        lucas_carmichael_numbers_in_range($x, $y, $n, sub ($k) {
            push @v, $k;
        });
        @v = sort { $a <=> $b } @v;
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (35) {
    say "a($n) = ", a($n);
}
