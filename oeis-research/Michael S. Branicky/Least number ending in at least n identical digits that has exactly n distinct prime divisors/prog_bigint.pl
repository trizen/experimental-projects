#!/usr/bin/perl

# a(n) is the least number ending in at least n identical digits that has exactly n distinct prime divisors.
# https://oeis.org/A389187

# Known terms:
#   2, 22, 222, 6666, 111111, 222222, 462222222, 58422222222, 11523666666666, 1141362222222222, 42481455555555555, 1173711888888888888

use 5.036;
use strict;
use warnings;
use Sidef      qw();
use Math::GMPz qw();

sub a($n, $from = 0) {

    my $n_obj = bless(\$n, 'Sidef::Types::Number::Number');
    my $u     = Math::GMPz::Rmpz_init();

    my $Rn = Math::GMPz::Rmpz_init();    # (10^n - 1)/9
    Math::GMPz::Rmpz_ui_pow_ui($Rn, 10, $n);
    Math::GMPz::Rmpz_sub_ui($Rn, $Rn, 1);
    Math::GMPz::Rmpz_div_ui($Rn, $Rn, 9);

    my $pow10 = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_ui_pow_ui($pow10, 10, $n);    # 10^n

    for (my $d = $from ; ; $d++) {
        my $start = Math::GMPz::Rmpz_init_set_ui(0);    # 10^(d-1)

        if ($d) {
            $start = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_ui_pow_ui($start, 10, $d - 1);
        }

        my $end = Math::GMPz::Rmpz_init();              # 10^d
        Math::GMPz::Rmpz_ui_pow_ui($end, 10, $d);

        say "Testing: $d -- ", $start * $pow10 + $Rn;

        for (my $r = $start ; Math::GMPz::Rmpz_cmp($r, $end) < 0 ; Math::GMPz::Rmpz_add_ui($r, $r, 1)) {

            for my $m (1 .. 9) {
                Math::GMPz::Rmpz_mul_ui($u, $Rn, $m);
                Math::GMPz::Rmpz_addmul($u, $r, $pow10);

                if (bless(\$u, 'Sidef::Types::Number::Number')->is_omega_prime($n_obj)) {
                    return $u;
                }
            }
        }
    }
}

foreach my $n (1 .. 9) {
    say "a($n) = ", a($n);
}

# Seaching for a(13)
say a(13, 8);

__END__
a(1) = 2
a(2) = 22
a(3) = 222
a(4) = 6666
a(5) = 111111
a(6) = 222222
a(7) = 462222222
a(8) = 58422222222
a(9) = 11523666666666
a(10) = 1141362222222222
a(11) = 42481455555555555
a(12) = 1173711888888888888
