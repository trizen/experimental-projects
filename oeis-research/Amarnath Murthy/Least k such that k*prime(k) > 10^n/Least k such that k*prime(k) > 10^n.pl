#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 26 February 2019
# https://github.com/trizen

# Given a positive integer n, find the smallest integer `k` such that `k*prime(k) > 10^n`.

# See also:
#   https://oeis.org/A090977 -- Least k such that k*prime(k) > 10^n.

use 5.010;
use strict;
use warnings;

use Math::AnyNum qw(:overload min max);
use ntheory qw( nth_prime_lower nth_prime_upper next_prime prev_prime);

sub bsearch_ge ($$;$) {
    my ($left, $right, $block) = @_;

    $left = Math::GMPz->new("$left");
    $right = Math::GMPz->new("$right");

    my $middle = Math::GMPz::Rmpz_init();

    while (1) {

        Math::GMPz::Rmpz_add($middle, $left, $right);
        Math::GMPz::Rmpz_div_2exp($middle, $middle, 1);

        my $cmp = do {
            local $_ = Math::AnyNum->new(Math::GMPz::Rmpz_init_set($middle));
            $block->($_, Math::AnyNum->new("$left"), Math::AnyNum->new("$right")) || return $_;
        };

        if ($cmp < 0) {
            Math::GMPz::Rmpz_add_ui($left, $middle, 1);

            if (Math::GMPz::Rmpz_cmp($left, $right) > 0) {
                Math::GMPz::Rmpz_add_ui($middle, $middle, 1);
                last;
            }
        }
        else {
            Math::GMPz::Rmpz_sub_ui($right, $middle, 1);
            Math::GMPz::Rmpz_cmp($left, $right) > 0 and last;
        }
    }

    Math::AnyNum->new($middle);
}

sub nth_prime {
    my ($n) = @_;
    chomp(my $p = `../primecount -n $n`);
    Math::AnyNum->new($p);
}

sub a {
    my ($n) = @_;

    no warnings 'exiting';

    my $lim = 10**$n;

    my $min_approx = int(sqrt($lim / log($lim+1)));
    my $max_approx = 2*$min_approx;

    my $min = bsearch_ge($min_approx, $max_approx, sub {
        nth_prime_upper($_) * $_ <=> $lim
    });

    my $max = bsearch_ge($min, $max_approx, sub {
        nth_prime_lower($_) * $_ <=> $lim
    });

    my @checkpoint;

    my $exact = bsearch_ge($min, $max, sub {
        my ($k, $left, $right) = @_;

        my $p = nth_prime($k);

        if ($right-$left < 10**6) {
            @checkpoint = ($p, $k);
            last;
        }

        say "p($_) = $p [ ", $right-$left, " ]";

        $p * $k <=> $lim
    });

    return $exact if !@checkpoint;

    my $p = $checkpoint[0];
    my $k = $checkpoint[1];

    if ($p*$k > $lim) {
        #say "prev branch";
        while ($p * $k > $lim){
            $p = prev_prime($p);
            --$k;
        }
        ++$k;
    }
    elsif ($p*$k < $lim) {
        #say "next branch";
        while ($p *$k < $lim){
            $p = next_prime($p);
            ++$k;
        }
    }

    #say "@checkpoint";

    #~ if ($k > $prev) {

        #~ while ($p * $k > $lim){
            #~ $p = prev_prime($p);
            #~ --$k;
        #~ }

        #~ ++$k;
    #~ }
    #~ else {

        #~ while ($p *$k < $lim){
            #~ $p = next_prime($p);
            #~ ++$k;
        #~ }

    #~ }

    #while ($p * $k < $lim) {
    #    say "Checking $k";
    #    $p = next_prime($p);
    #    ++$k;
    #}

    return $k;

    #say $prev;
    #say @checkpoint[1];
}

foreach my $n(1..22) {
    say "a($n) = ", a($n);
}

__END__
a(0) = 1
a(1) = 3
a(2) = 7
a(3) = 17
a(4) = 48
a(5) = 134
a(6) = 382
a(7) = 1115
a(8) = 3287
a(9) = 9786
a(10) = 29296
a(11) = 88181
a(12) = 266694
a(13) = 809599
a(14) = 2465574
a(15) = 7528976
a(16) = 23045352
a(17) = 70684657
a(18) = 217196605
a(19) = 668461874
a(20) = 2060257099
a(21) = 6358076827
a(22) = 19644205359
