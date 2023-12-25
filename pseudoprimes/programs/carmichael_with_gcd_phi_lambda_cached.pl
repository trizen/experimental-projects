#!/usr/bin/perl

# Carmichael numbers n such that gcd(n-1, phi(n))**2 / lambda(n)**2 >= n-1.

# Problem from:
#   https://math.stackexchange.com/questions/4157474/carmichael-number-n-such-that-frac-gcdn-1-phin2-lambdan2-geq-n

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use POSIX qw(ULONG_MAX);

#use Math::Sidef qw(is_fibonacci);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);
#use List::Util qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

sub my_euler_phi ($factors) {    # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_mul_ui($t, $t, $p - 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, "$p", 10);
            Math::GMPz::Rmpz_sub_ui($u, $u, 1);
            Math::GMPz::Rmpz_mul($t, $t, $u);
        }
    }

    return $t;
}

sub my_carmichael_lambda ($factors) {    # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_lcm_ui($t, $t, $p - 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, "$p", 10);
            Math::GMPz::Rmpz_sub_ui($u, $u, 1);
            Math::GMPz::Rmpz_lcm($t, $t, $u);
        }
    }

    return $t;
}

my $u = Math::GMPz::Rmpz_init_set_ui(0);
my $t = Math::GMPz::Rmpz_init_set_ui(0);

while(my($key, $value) = each %$carmichael) {

    my @factors = split(' ', $value);
    my $phi = my_euler_phi(\@factors);
    my $lambda = my_euler_phi(\@factors);

    Math::GMPz::Rmpz_set_str($u, $key, 10);
    Math::GMPz::Rmpz_sub_ui($u, $u, 1);
    Math::GMPz::Rmpz_gcd($t, $u, $phi);
    Math::GMPz::Rmpz_mul($t, $t, $t);
    Math::GMPz::Rmpz_mul($lambda, $lambda, $lambda);
    Math::GMPz::Rmpz_divexact($t, $t, $lambda);

    if (Math::GMPz::Rmpz_cmp($t, $u) >= 0) {
        say $key;
    }
}

__END__

# No such number is known...
