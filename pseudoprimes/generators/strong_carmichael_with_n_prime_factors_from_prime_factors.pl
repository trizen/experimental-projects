#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 24 September 2022
# https://github.com/trizen

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);
use Math::GMPz;

sub divceil ($x, $y) {    # ceil(x/y)
    my $q = ($x / $y);
    ($q * $y == $x) ? $q : ($q + 1);
}

sub strong_fermat_psp_in_range ($A, $B, $k, $base, $primes, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    if ($A > $B) {
        return;
    }

    my $end = $#{$primes};

    my $k_exp = 1;
    my $congr = -1;

    sub ($m, $lambda, $j, $k) {

        my $y = rootint(($B / $m), $k);

        if ($k == 1) {

            my $x = divceil($A, $m);

            if ($primes->[-1] < $x) {
                return;
            }

            foreach my $i ($j .. $end) {
                my $p = $primes->[$i];

                last if ($p > $y);
                next if ($p < $x);

                my $valuation = valuation($p - 1, 2);
                ($valuation > $k_exp and powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p)) || next;

                my $t = $m * $p;

                if (($t - 1) % $lambda == 0 and ($t - 1) % ($p-1) == 0) {
                    $callback->($t);
                }
            }

            return;
        }

        foreach my $i ($j .. $end) {
            my $p = $primes->[$i];
            last if ($p > $y);

            $base % $p == 0 and next;

            my $valuation = valuation($p - 1, 2);
            $valuation > $k_exp                                                    or next;
            powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

            my $L = lcm($lambda, $p-1);
            gcd($L, $m) == 1 or next;

            my $t = $m * $p;
            my $u = divceil($A, $t);
            my $v = ($B / $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $i + 1, $k - 1);
            }
        }
      }
      ->(Math::GMPz->new(1), 1, 0, $k);
}

use IO::Handle;

open my $fh, '>>', 'strong_carmichael.txt';
$fh->autoflush(1);

#~ a(12) <= 27146803388402594456683201
#~ a(13) <= 1793888484612948579347804219906251
#~ a(14) <= 189584826452674863676897122014401
#~ a(15) <= 82118192385977491711980768883709401

my %upper_bounds = (
    11 => Math::GMPz->new("40458813831093914176528685701"),
    12 => Math::GMPz->new("27146803388402594456683201"),
    13 => Math::GMPz->new("1793888484612948579347804219906251"),
    14 => Math::GMPz->new("189584826452674863676897122014401"),
    15 => Math::GMPz->new("82118192385977491711980768883709401"),
    #~ 19 => Math::GMPz->new("639480457556385948331213272814418836890728227501"),
    #~ 20 => Math::GMPz->new("639480457556385948331213272814418836890728227501000"),
);

use List::Util qw(shuffle);

#foreach my $lambda (80000 .. 1e6) {
foreach my $lambda (shuffle 812700, 139230, 3197250, 4709250, 4709250, 2174130, 8824410, 20396250, 10442250, 982800, 7068600, 116953200, 88, 360, 3024, 12852, 8400, 39984, 18900, 486864, 529200) {
#while (<>) {
#    chomp(my $lambda = $_);

    #$lambda >= 96600 or next;

    say "# Generating: $lambda";

    my @primes = grep { $_ > 2 and $lambda % $_ != 0 and $_ <= 3000 and is_prime($_) } map { $_ + 1 } divisors($lambda);

    foreach my $k (11..15) {
        #if (binomial(scalar(@primes), $k) < 1e6) {
            strong_fermat_psp_in_range(Math::GMPz->new(~0), $upper_bounds{$k}, $k, 2, \@primes, sub ($n) { say $n; say $fh $n; });
        #}
    }
}
