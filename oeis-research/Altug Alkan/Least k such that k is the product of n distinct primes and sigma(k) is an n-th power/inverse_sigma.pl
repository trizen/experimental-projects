#!/usr/bin/perl

# Least k such that k is the product of n distinct primes and sigma(k) is an n-th power.
# https://oeis.org/A281140

# a(14) <= 94467020965716904490370

use utf8;
use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

sub dynamicPreimage ($N, $L) {

    if (ref($N)) {
        $N = Math::GMPz->new("$N");
    }

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            fordivisors {
                my $d = $_;
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            } divint($N, $x);
        }

        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    $r{$N};
}

sub dynamicPreimageLen ($N, $L) {

    if (ref($N)) {
        $N = Math::GMPz->new("$N");
    }

    my %r = (1 => 1);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            fordivisors {
                my $d = $_;
                if (exists $r{$d}) {
                    my $key = mulint($x, $d);
                    $t{$key} //= 0;
                    $t{$key} += $r{$d};
                }
            } divint($N, $x);
        }

        while (my ($k, $v) = each %t) {
            $r{$k} //= 0;
            $r{$k} += $v;
        }
    }

    $r{$N} // 0;
}

sub cook_sigma ($N, $k) {
    my %L;

    fordivisors {
        my $d = $_;

        if ($d == 1) {
            ## ok
        }
        else {

            foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

                my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
                my $t = valuation($q, $p);

                if (ref($q)) {
                    $q = Math::GMPz->new("$q");
                }

                if ($t <= $k or ($t % $k) or $q != powint($p, $t)) {
                    ## ok
                }
                else {
                    push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
                }
            }
        }
    }
    $N;

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    dynamicPreimage($N, cook_sigma($N, $k));
}

sub inverse_sigma_len ($N, $k = 1) {
    dynamicPreimageLen($N, cook_sigma($N, $k));
}

sub a ($n) {

    my @list;

    foreach my $k (2 .. 1e9) {

        is_smooth($k, 3) || next;
        inverse_sigma_len(powint($k, $n)) <= 2e6 or next;

        my $solutions = inverse_sigma(powint($k, $n)) // next;

        foreach my $v (@$solutions) {
            if (is_square_free($v) and is_almost_prime($n, $v)) {
                push @list, $v;
            }
        }

        last if @list;
    }

    vecmin(@list);
}

foreach my $n (1 .. 20) {
    say "a($n) <= ", a($n);
}

__END__
a(1) <= 2
a(2) <= 22
a(3) <= 102
a(4) <= 510
a(5) <= 90510
a(6) <= 995610
a(7) <= 11616990
a(8) <= 130258590
a(9) <= 1483974030
a(10) <= 18404105922510
a(11) <= 428454465915630
a(12) <= 10195374973815570
a(13) <= 240871269907008510
