#!/usr/bin/perl

# Numbers k > 1 such that 2^(k-1) == (2*k + 1) (mod k^2).
# https://oeis.org/A175863

# Try to find composite terms of A175863.

use 5.036;
use Math::GMPz;
use ntheory                qw(:all);
use Math::Prime::Util::GMP qw();

my $k = Math::GMPz::Rmpz_init();
my $ksqr = Math::GMPz::Rmpz_init();
my $km1 = Math::GMPz::Rmpz_init();
my $k2p1 = Math::GMPz::Rmpz_init();
my $two = Math::GMPz::Rmpz_init_set_ui(2);

while (<>) {

    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n > ~0 or next;

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    Math::GMPz::Rmpz_set_str($ksqr, $n, 10);
    Math::GMPz::Rmpz_sub_ui($km1, $ksqr, 1);
    Math::GMPz::Rmpz_mul_2exp($k2p1, $ksqr, 1);
    Math::GMPz::Rmpz_add_ui($k2p1, $k2p1, 1);
    Math::GMPz::Rmpz_mul($ksqr, $ksqr, $ksqr);

    Math::GMPz::Rmpz_powm($km1, $two, $km1, $ksqr);

    if (Math::GMPz::Rmpz_cmp($km1, $k2p1) == 0) {
        say $n;
    }
}

__END__

# No composite terms are known...
