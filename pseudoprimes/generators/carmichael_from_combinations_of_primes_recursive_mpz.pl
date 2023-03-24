#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 17 March 2023
# https://github.com/trizen

# Generate Carmichael numbers from a given multiple.

# See also:
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.036;
use Math::GMPz;

#use ntheory qw(:all);
use Math::Sidef qw(:all);
use ntheory     qw(vecall forcomb);

sub carmichael_from_multiple ($m, $callback, $reps = 1e4) {

    my $t = Math::GMPz::Rmpz_init();
    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    is_square_free($m) || return;

    my $L = lambda($m);

    $m = Math::GMPz->new("$m");
    $L = Math::GMPz->new("$L");

    Math::GMPz::Rmpz_invert($v, $m, $L) || return;

    for (my $p = Math::GMPz::Rmpz_init_set($v) ; --$reps > 0 ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        $p > 1 or next;

        Math::GMPz::Rmpz_gcd($t, $m, $p);
        Math::GMPz::Rmpz_cmp_ui($t, 1) == 0 or next;

        is_square_free($p) || next;

        Math::GMPz::Rmpz_mul($v, $m, $p);
        Math::GMPz::Rmpz_sub_ui($u, $v, 1);

        Math::GMPz::Rmpz_set_str($t, lambda($p), 10);

        if (Math::GMPz::Rmpz_divisible_p($u, $t)) {
            $callback->(Math::GMPz::Rmpz_init_set($v));
        }
    }
}

my %seen;
my @primes;

#foreach my $p (almost_primes(2, 10000, 100000)) {
while (<>) {
    my $p = (split(' ', $_))[-1];
    $p =~ /^\d+\z/ or next;

    #$p > 2000 or next;
    #  log($p)/log(10) > 100 or next;

    next if $seen{$p}++;

    is_square_free($p) || next;
    $p = Math::GMPz->new("$p");

    push @primes, $p;
}

#foreach my $p (@primes) {
forcomb {

    my $p = Math::GMPz->new(join '', prod(@primes[@_]));

    if (lambda($p) < iroot($p, 3)->sqr) {

        say "# Sieving with p = $p";

        my @list = ($p);

        while (@list) {
            my $m = shift(@list);
            $seen{$m} = 1;
            carmichael_from_multiple(
                $m,
                sub ($n) {
                    if ($n > $m) {
                        if ($n > ~0) {
                            say $n;
                        }
                        if (!$seen{$n}++) {
                            push @list, $n;
                        }
                    }
                }
            );
        }
    }
} scalar(@primes), 2;
