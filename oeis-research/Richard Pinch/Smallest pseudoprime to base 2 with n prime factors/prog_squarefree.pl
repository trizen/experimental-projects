#!/usr/bin/perl

# a(n) = smallest pseudoprime to base 2 with n prime factors.
# https://oeis.org/A007011

# Known terms:
#   341, 561, 11305, 825265, 45593065, 370851481, 38504389105, 7550611589521, 277960972890601, 32918038719446881, 1730865304568301265, 606395069520916762801, 59989606772480422038001, 6149883077429715389052001, 540513705778955131306570201, 35237869211718889547310642241

# Lower-bounds:
#   a(33) > 549407656919731418096241718792164293317568547009840344974835958463
#   a(34) > 76367664311842667115377598912110836771142028034367807425335971762323

# Upper-bounds:
#   a(35) <= 39861441152136913409974961298453657087970515495885529645785368112405601

# It took 2 hours and 12 minutes to find a(30).
# It took 5 hours to find a(32).
# It took 3 hours and 45 minutes to find a(33).
# It took 1 hour and 5 minutes to find a(34).

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub squarefree_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

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
                if (is_prime($p) and $base % $p != 0) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, znorder($base, $p))) {
                        my $value = Math::GMPz::Rmpz_init_set($v);
                        say "Found upper-bound: $value";
                        $B = $value if ($value < $B);
                        $callback->($value);
                    }
                }
            }

            return;
        }

        my $t   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;
            my $z = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);
            Math::GMPz::Rmpz_mul_ui($t, $m, $p);

            __SUB__->($t, $lcm, $p + 1, $k - 1);
        }
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    say "Searching for a($n)";

    my $x = Math::GMPz->new(pn_primorial($n));
    my $y = 2*$x;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v;
        squarefree_fermat_pseudoprimes_in_range($x, $y, $n, 2, sub ($k) {
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

__END__
2 341
3 561
4 11305
5 825265
6 45593065
7 370851481
8 38504389105
9 7550611589521
10 277960972890601
11 32918038719446881
12 1730865304568301265
13 606395069520916762801
14 59989606772480422038001
15 6149883077429715389052001
16 540513705778955131306570201
17 35237869211718889547310642241
18 13259400431578770557375638157521
19 580827911915963785382253469211401
20 292408776547176479576081475390697801
21 39498823114155235923831808284152901601
22 3284710806953570725820888298298841565601
23 327373784481535488655521620744179013043601
24 221404014114397213806721960178887462402717201
25 43691666165877828056799483424028795272585383601
26 13213974925373194568934435211730355813060799098001
27 1952204134080476076724242017017925744953021675628161
28 633922683896008820507659141940205847766668463614120801
29 208615777921466463779477993429576353802684390620173966001
30 44091058061027666417635106691235215695970713110442194459201
31 2884167509593581480205474627684686008624483147814647841436801
32 2214362930783528605057288166084711828471950070626477770522049201
33 846160422741542455111837894473050187248594912573350734967810185601
34 152871247604711789212068696541727000750702435080280578363228173885601
