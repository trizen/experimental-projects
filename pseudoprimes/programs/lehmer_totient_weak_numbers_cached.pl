#!/usr/bin/perl

# Composite numbers n such that phi(n) divides p*(n - 1) for some prime factor p of n-1.
# https://oeis.org/A338998

# Known terms:
#   1729, 12801, 5079361, 34479361, 3069196417

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use Math::Sidef qw(trial_factor);
use List::Util qw(uniq);
use POSIX qw(ULONG_MAX);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael      = retrieve($carmichael_file);

#~ sub my_euler_phi ($factors) {    # assumes n is squarefree
    #~ Math::Prime::Util::GMP::vecprod(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);
#~ }

sub my_euler_phi ($factors) { # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_mul_ui($t, $t, $p - 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, $p, 10);
            Math::GMPz::Rmpz_sub_ui($u, $u, 1);
            Math::GMPz::Rmpz_mul($t, $t, $u);
        }
    }

    return $t;
}

sub is_smooth_over_prod ($n, $k) {

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_set($t, $n);
    Math::GMPz::Rmpz_gcd($g, $t, $k);

    while (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_remove($t, $t, $g);
        return 1 if Math::GMPz::Rmpz_cmp_ui($t, 1) == 0;
        Math::GMPz::Rmpz_gcd($g, $t, $g);
    }

    return 0;
}

my $t   = Math::GMPz::Rmpz_init();
my $nm1 = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %$carmichael) {

    # length($key) <= 30 or next;

    Math::GMPz::Rmpz_set_str($nm1, $key, 10);
    Math::GMPz::Rmpz_sub_ui($nm1, $nm1, 1);

    my @factors = split(' ', $value);
    my $phi = my_euler_phi(\@factors);

    Math::GMPz::Rmpz_gcd($t, $phi, $nm1);
    Math::GMPz::Rmpz_divexact($t, $phi, $t);

    #~ if (Math::GMPz::Rmpz_divisible_p($nm1, $t)) {
    if (Math::GMPz::Rmpz_divisible_p($nm1, $t)) {
        if (is_prime(Math::GMPz::Rmpz_get_str($t, 10))) {
            say "\nFound term: $key\n";
        }
        else {
            say "$t -> ", $key;
        }
    }
}

__END__

# No terms > 2^64 are known.

# If we relax the problem such that k is allowed to be composite, then we have (k -> n):

256 -> 161053591977104597648385
164647296 -> 710498768604458891905
239368932 -> 166767515214109647553
239855616 -> 69331699150300274689
344198160 -> 26220447360756492481
470271360 -> 22577695684076482561
690069744 -> 26412091255782290298241
847888206 -> 508856401419300817312321
1022867120 -> 151320171400394261761
1355878368 -> 25043558587894400823361
1713960000 -> 405475097425913520001
2595175200 -> 79919351614524024001
3936306240 -> 22695373452873769921
4766062840 -> 305022961592329915047961
5256049760 -> 1454162635820073015201
9337407520 -> 588513459619254160321
22016352600 -> 43988320199517413227201
14246648367828 -> 7429200724594400259443892735745
