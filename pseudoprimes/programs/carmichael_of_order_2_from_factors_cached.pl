#!/usr/bin/perl

# Carmichael numbers of order 2.
# https://oeis.org/A175531

# Try to generate large Carmichael numbers of order 2.

use 5.036;
use Storable;
use Math::GMPz;
use ntheory    qw(:all);
use List::Util qw(uniq);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $table         = retrieve($storable_file);

sub carmichael_from_multiple ($factors, $m, $callback, $reps = 1e4) {

    my $t = Math::GMPz::Rmpz_init();
    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my $smooth_lambda = 83;

    (vecall { is_smooth(subint($_,             1), $smooth_lambda) } @$factors) || return;
    (vecall { is_smooth(subint(mulint($_, $_), 1), $smooth_lambda) } @$factors) || return;

    my $L = Math::Prime::Util::GMP::lcm(map { subint(mulint($_, $_), 1) } @$factors);

    $m = Math::GMPz->new("$m");
    $L = Math::GMPz->new("$L");

    Math::GMPz::Rmpz_invert($v, $m, $L) || return;

    say "# Checking m = $m";

    for (my $p = Math::GMPz::Rmpz_init_set($v) ; --$reps >= 0 ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        Math::GMPz::Rmpz_gcd($t, $m, $p);
        Math::GMPz::Rmpz_cmp_ui($t, 1) == 0 or next;

        Math::GMPz::Rmpz_mul($v, $m, $p);

        if (!Math::GMPz::Rmpz_fits_ulong_p($p)) {
            Math::Prime::Util::GMP::is_pseudoprime($v, 2) || next;
        }

        my @factors = factor_exp($p);
        (vecall { $_->[1] == 1 } @factors) || next;

        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
        Math::GMPz::Rmpz_set_str($t, lcm(map { subint(mulint($_->[0], $_->[0]), 1) } @factors), 10);

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
    #$factors[-1] < 1e3 and next;
    $factors[-1] < 1e3 or next;

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
