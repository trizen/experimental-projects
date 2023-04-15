#!/usr/bin/perl

# Try to generate a Carmichael number that is also Lucas-Carmichael.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $table         = retrieve($storable_file);

use 5.036;
use Math::GMPz;
use ntheory    qw(:all);
use List::Util qw(uniq);

sub carmichael_from_multiple ($factors, $m, $callback, $reps = 1e4) {

    my $t = Math::GMPz::Rmpz_init();
    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my @congr = uniq(map { $_ % 12 } @$factors);
    scalar(@congr) == 1 or return;

    my $L1 = Math::Prime::Util::GMP::lcm(map { subint($_, 1) } @$factors);
    my $L2 = Math::Prime::Util::GMP::lcm(map { addint($_, 1) } @$factors);

    Math::Prime::Util::GMP::gcd($L1, $L2) eq '2' or return;

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

    say "# Checking m = $m with c = $c";

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

while (my ($key, $value) = each %$table) {

    my @factors = split(' ', $value);

    #$factors[-1] < ~0 or next;
    $factors[-1] < 1e4 and next;
    $factors[-1] < 1e6 or next;

    my @list = ($key);

    while (@list) {
        my $m = shift(@list);
        carmichael_from_multiple(
            \@factors,
            $m,
            sub ($n) {
                if ($n > $m) {
                    say $n;
                    push @list, $n;
                }
            }
        );
    }
}
