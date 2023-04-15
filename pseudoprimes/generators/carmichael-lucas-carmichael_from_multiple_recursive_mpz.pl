#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 17 March 2023
# Edit: 29 March 2023
# https://github.com/trizen

# Generate Carmichael numbers from a given multiple, that are *almost* Lucas-Carmichael numbers.

# Examples:
#   2465, 8911, 1152271, 5444489, 19384289, 26921089, 67902031, 120981601, 227752993, 962442001, 9701285761, 24213909889, 24899816449, 25862624705, 66243263297, 1101573374329, 1110913126273, 129235662445121, 131314855918751, 443372888629441, 2562406036159969, 21529700665395121

# See also:
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.036;
use Math::GMPz;
use ntheory    qw(:all);
use List::Util qw(uniq);

sub carmichael_from_multiple ($m, $callback, $reps = 1e4) {

    my $t = Math::GMPz::Rmpz_init();
    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    is_square_free($m) || return;

    my @f = factor($m);

    my @congr = uniq(map { $_ % 12 } @f);
    scalar(@congr) == 1 or return;

    my $L1 = lcm(map { subint($_, 1) } @f);
    my $L2 = lcm(map { addint($_, 1) } @f);

    gcd($L1, $L2) == 2 or return;

    $m  = Math::GMPz->new("$m");
    $L1 = Math::GMPz->new("$L1");
    $L2 = Math::GMPz->new("$L2");

    Math::GMPz::Rmpz_invert($v, $m, $L1) || return;

    my $x = Math::GMPz::Rmpz_init_set($v);

    Math::GMPz::Rmpz_invert($v, $m, $L2) || return;
    Math::GMPz::Rmpz_sub($v, $L2, $v);

    my $y = Math::GMPz::Rmpz_init_set($v);

    if (Math::GMPz::Rmpz_fits_ulong_p($L1)) {
        $L1 = Math::GMPz::Rmpz_get_ui($L1);
    }

    if (Math::GMPz::Rmpz_fits_ulong_p($L2)) {
        $L2 = Math::GMPz::Rmpz_get_ui($L2);
    }

    my $c  = chinese([$x, $L1], [$y, $L2]) || return;
    my $L3 = Math::GMPz->new(lcm($L1, $L2));

    for (my $p = Math::GMPz::Rmpz_init_set_str("$c", 10) ; --$reps >= 0 ; Math::GMPz::Rmpz_add($p, $p, $L3)) {

        Math::GMPz::Rmpz_gcd($t, $m, $p);
        Math::GMPz::Rmpz_cmp_ui($t, 1) == 0 or next;

        Math::GMPz::Rmpz_mul($v, $m, $p);

        if (!Math::GMPz::Rmpz_fits_ulong_p($p)) {
            Math::Prime::Util::GMP::is_pseudoprime($v, 2) || next;
        }

        my @factors = factor_exp($p);

        (vecall { $_->[1] == 1 } @factors)                     || next;
        (vecall { modint($_->[0], 12) == $congr[0] } @factors) || next;

        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
        Math::GMPz::Rmpz_set_str($t, lcm(map { subint($_->[0], 1) } @factors), 10);

        if (Math::GMPz::Rmpz_divisible_p($u, $t)) {
            $callback->(Math::GMPz::Rmpz_init_set($v));

            Math::GMPz::Rmpz_set_str($t, lcm(map { addint($_->[0], 1) } @factors), 10);
            Math::GMPz::Rmpz_add_ui($u, $v, 1);

            if (Math::GMPz::Rmpz_divisible_p($u, $t)) {
                die "Found counter-example: $v";
            }
        }
    }
}

my %seen;

while (<>) {

    next if /^#/;
    my $p = (split(' ', $_))[-1];
    $p || next;
    $p =~ /^\d+\z/ or next;
    $p < ~0 or next;

    scalar(uniq(map { $_ % 12 } factor($p))) == 1 or next;

    next if $seen{$p}++;

    say "# Sieving with p = $p";

    my @list = ($p);

    while (@list) {
        my $m = shift(@list);
        carmichael_from_multiple(
            $m,
            sub ($n) {
                if ($n > $m) {

                    #if ($n > ~0) {
                        say $n;
                    #}

                    push @list, $n;
                }
            }
        );
    }
}
