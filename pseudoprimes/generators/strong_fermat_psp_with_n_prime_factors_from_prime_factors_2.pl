#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 24 September 2022
# https://github.com/trizen

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

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

                if (($t - 1) % $lambda == 0 and ($t - 1) % znorder($base, $p) == 0) {
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

            my $L = lcm($lambda, znorder($base, $p));
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

open my $fh, '>>', 'strong_fermat4.txt';
$fh->autoflush(1);

my %upper_bounds = (
    14 => Math::GMPz->new("11204126171093532395238176008628640001"),
    15 => Math::GMPz->new("52763042375348388525807775606810431553349251"),
    16 => Math::GMPz->new("8490206016886862443343349923062834577705405389801"),
    17 => Math::GMPz->new("16466175808047026414728161638977648257386104008228485611"),
    18 => Math::GMPz->new("5344281976789774350298352596501700430295430104885257558315750001"),
    19 => Math::GMPz->new("70431557151301737035704584760444098436791955264321945298355949864521755311"),
    20 => Math::GMPz->new("70431557151301737035704584760444098436791955264321945298355949864521755311425489"),
    21 => Math::GMPz->new("70431557151301737035704584760444098436791955264321945298355949864521755311425489388304"),
    22 => Math::GMPz->new("7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450"),
    23 => Math::GMPz->new("704315571513017370357045847604440984367919552643219452983559498645217553114254893883045010"),
    24 => Math::GMPz->new("7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109"),
    25 => Math::GMPz->new("70431557151301737035704584760444098436791955264321945298355949864521755311425489388304501092"),
    26 => Math::GMPz->new("704315571513017370357045847604440984367919552643219452983559498645217553114254893883045010925"),
    27 => Math::GMPz->new("7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109251"),
);

#foreach my $lambda (80000 .. 1e6) {
#foreach my $lambda (sort {$a<=>$b} 812700, 139230, 3197250, 4709250, 4709250, 2174130, 8824410, 20396250, 10442250, 982800, 7068600, 116953200, 88, 360, 3024, 12852, 8400, 39984, 18900, 486864, 529200) {
while (<>) {
    chomp(my $lambda = $_);

    #$lambda >= 96600 or next;

    say "# Generating: $lambda";

    my @primes = grep { $_ > 2 and $lambda % $_ != 0 and is_prime($_) } map { $_ + 1 } divisors($lambda);

    foreach my $k (14..27) {
        #if (binomial(scalar(@primes), $k) < 1e6) {
            strong_fermat_psp_in_range(Math::GMPz->new(~0), $upper_bounds{$k}, $k, 2, \@primes, sub ($n) { say $n; say $fh $n; });
        #}
    }
}
