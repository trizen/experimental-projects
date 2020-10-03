#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(is_prime kronecker);

sub is_fermat_fibonacci_prime($n) {

    if (ref($n) eq 'Math::GMPz') {
        $n = Math::GMPz::Rmpz_init_set($n);
    }
    else {
        $n = Math::GMPz->new("$n");
    }

    if (Math::GMPz::Rmpz_even_p($n)) {
        return ((Math::GMPz::Rmpz_cmp_ui($n, 2) == 0) ? 1 : 0);
    }

    if (Math::GMPz::Rmpz_cmp_ui($n, 5) == 0) {
        return 1;
    }

    my $t = Math::GMPz::Rmpz_init_set_ui(2);
    my $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_sub_ui($u, $n, 1);
    Math::GMPz::Rmpz_powm($u, $t, $u, $n);
    Math::GMPz::Rmpz_cmp_ui($u, 1) == 0 or return 0;

    my $v = Math::GMPz::Rmpz_init();
    my $w = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_sub_ui($w, $n, 1);

    my $m = Math::GMPz::Rmpz_init_set($n);
    my $f = Math::GMPz::Rmpz_init_set_ui(0);
    my $g = Math::GMPz::Rmpz_init_set_ui(1);

    my $a = Math::GMPz::Rmpz_init_set_ui(0);
    my $b = Math::GMPz::Rmpz_init_set_ui(1);
    my $c = Math::GMPz::Rmpz_init_set_ui(1);
    my $d = Math::GMPz::Rmpz_init_set_ui(1);

    for (; ;) {

        if (Math::GMPz::Rmpz_odd_p($n)) {
            Math::GMPz::Rmpz_set($t, $f);
            Math::GMPz::Rmpz_mul($f, $f, $a);
            Math::GMPz::Rmpz_addmul($f, $g, $c);
            Math::GMPz::Rmpz_mod($f, $f, $m);

            Math::GMPz::Rmpz_mul($g, $g, $d);
            Math::GMPz::Rmpz_addmul($g, $t, $b);
            Math::GMPz::Rmpz_mod($g, $g, $m);
        }

        Math::GMPz::Rmpz_div_2exp($n, $n, 1);
        Math::GMPz::Rmpz_sgn($n) || last;

        Math::GMPz::Rmpz_set($t, $a);
        Math::GMPz::Rmpz_mul($a, $a, $a);
        Math::GMPz::Rmpz_addmul($a, $b, $c);
        Math::GMPz::Rmpz_mod($a, $a, $m);

        Math::GMPz::Rmpz_set($u, $b);
        Math::GMPz::Rmpz_mul($b, $b, $d);
        Math::GMPz::Rmpz_addmul($b, $u, $t);
        Math::GMPz::Rmpz_mod($b, $b, $m);

        Math::GMPz::Rmpz_set($v, $c);
        Math::GMPz::Rmpz_mul($c, $c, $t);
        Math::GMPz::Rmpz_addmul($c, $v, $d);
        Math::GMPz::Rmpz_mod($c, $c, $m);

        Math::GMPz::Rmpz_mul($d, $d, $d);
        Math::GMPz::Rmpz_addmul($d, $v, $u);
        Math::GMPz::Rmpz_mod($d, $d, $m);
    }

    if (   Math::GMPz::Rmpz_cmp_ui($f, 1) == 0
        or Math::GMPz::Rmpz_cmp($f, $w) == 0) {

        if (not is_prime($w + 1)) {
            say "error for ", $w + 1, " -> with $f";
        }
        return 1;
    }

    return 0;
}

my %seen;
my @nums;
while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    next if $seen{$n}++;

    #say $. if $. % 10000 == 0;

    #if ($n >= (~0 >> 1)) {
    $n = Math::GMPz->new("$n");

    #}

    push @nums, $n;

    #ntheory::is_provable_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}

@nums = sort { $a <=> $b } @nums;

foreach my $n (@nums) {
    is_fermat_fibonacci_prime($n) && do {
        warn "error: $n\n";
        last;
    };
}
