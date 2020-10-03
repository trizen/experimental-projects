#!/usr/bin/perl

# Palindromes of form n^2 + (n+1)^2.
# https://oeis.org/A027572

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use Set::Product::XS qw(product);
use ntheory qw(sqrtmod factor_exp chinese);

sub next_palindrome ($n) {

    my @d = split(//, $n);
    my $l = $#d;
    my $i = ((scalar(@d) + 1) >> 1) - 1;

    while ($i >= 0 and $d[$i] == 9) {
        $d[$i] = 0;
        $d[$l - $i] = 0;
        $i--;
    }

    if ($i >= 0) {
        $d[$i]++;
        $d[$l - $i] = $d[$i];
    }
    else {
        @d     = (0) x (scalar(@d) + 1);
        $d[0]  = 1;
        $d[-1] = 1;
    }

    join('', @d);
}

sub sum_of_two_squares_solutions ($n) {

    $n == 0 and return [0, 0];

    my $prod1 = 1;
    my $prod2 = 1;

    my @prime_powers;

    foreach my $f (factor_exp($n)) {
        if ($f->[0] % 4 == 3) {    # p = 3 (mod 4)
            $f->[1] % 2 == 0 or return;    # power must be even
            $prod2 *= Math::GMPz->new($f->[0])**($f->[1] >> 1);
        }
        elsif ($f->[0] == 2) {             # p = 2
            if ($f->[1] % 2 == 0) {        # power is even
                $prod2 *= Math::GMPz->new($f->[0])**($f->[1] >> 1);
            }
            else {                         # power is odd
                $prod1 *= $f->[0];
                $prod2 *= Math::GMPz->new($f->[0])**(($f->[1] - 1) >> 1);
                push @prime_powers, [$f->[0], 1];
            }
        }
        else {                             # p = 1 (mod 4)
            $prod1 *= Math::GMPz->new($f->[0])**$f->[1];
            push @prime_powers, $f;
        }
    }

    $prod1 == 1 and return [$prod2, 0];
    $prod1 == 2 and return [$prod2, $prod2];

    my %table;
    foreach my $f (@prime_powers) {
        my $pp = Math::GMPz->new($f->[0])**$f->[1];
        my $r  = sqrtmod($pp - 1, $pp);
        push @{$table{$pp}}, [$r, $pp], [$pp - $r, $pp];
    }

    my @square_roots;

    product {
        push @square_roots, Math::GMPz->new(chinese(@_));
    }
    values %table;

    my @solutions;

    foreach my $r (@square_roots) {

        my $s = $r;
        my $q = $prod1;

        while ($s * $s > $prod1) {
            ($s, $q) = ($q % $s, $s);
        }

        push @solutions, [$prod2 * $s, $prod2 * ($q % $s)];
    }

    foreach my $f (@prime_powers) {
        for (my $i = $f->[1] % 2 ; $i < $f->[1] ; $i += 2) {

            my $sq = Math::GMPz->new($f->[0])**(($f->[1] - $i) >> 1);
            my $pp = Math::GMPz->new($f->[0])**($f->[1] - $i);

            push @solutions, map {
                [map { $sq * $prod2 * $_ } @$_]
            } __SUB__->($prod1 / $pp);
        }
    }

    return sort { $a->[0] <=> $b->[0] } do {
        my %seen;
        grep { !$seen{$_->[0]}++ } map {
            [sort { $a <=> $b } @$_]
        } @solutions;
    };
}

use ntheory qw(vecany);

sub isok ($n) {
    my @solutions = sum_of_two_squares_solutions($n);
    @solutions || return;
    vecany { $_->[1] == (1 + $_->[0]) } @solutions;
}

# Terms from https://oeis.org/A027571
foreach my $n (
               qw(
               5 181 313 545 1690961 3162613 3187813 5258525 5824285
               58281418285 1635446445361 3166046406613 124852060258421
               149988757889941 310433303334013 582818040818285
               12951570707515921 5227371841481737225 5649436330336349465 5816694029204966185
               108348382545283843801 129052205999502250921 129776662212266677921 316234169939961432613
               564080816010618080465 54488716319691361788445 1427056470511150746507241 3130000999262629990000313
               3153012324698964232103513 3169345937085807395439613 5054998070382830708994505
               )
  ) {
    isok($n) || die "error for $n";
}

$| = 1;

# OVERFLOW at n = 3037000500

foreach my $n (0 .. 3037000500) {
    my $t = $n * $n + ($n + 1) * ($n + 1);
    if ($t eq reverse $t) {
        print($t, ", ");
    }
}

__END__

# a = 80472264
use POSIX qw(ULONG_MAX);

local $| = 1;

use Math::GMPz;
my $t = Math::GMPz::Rmpz_init_nobless();

# x ≈ 7071067811

my $from = 1616689803;

foreach my $n ($from .. 1e12) {

    #my $t = $n*$n + ($n+1)*($n+1);

    Math::GMPz::Rmpz_set_ui($t, $n);
    Math::GMPz::Rmpz_mul_ui($t, $t, 2 * $n + 2);
    Math::GMPz::Rmpz_add_ui($t, $t, 1);

    #if ($t > ULONG_MAX) {
    #    say "t = $t";
    #    die "OVERFLOW at n = $n\n";
    #}

    my $str = Math::GMPz::Rmpz_get_str($t, 10);

    if ($str eq scalar(reverse($str))) {
        print($str, ", ");
    }
}

__END__

my $n = "149988767889941"; #, 149988757889941,;
local $| = 1;

while (1) {

    my @solutions = sum_of_two_squares_solutions($n);

    if (@solutions) {
        if (vecany { $_->[1] == (1+$_->[0]) } @solutions) {
            print($n, ", ");
        }
    }

    $n = next_palindrome($n);
}

__END__
