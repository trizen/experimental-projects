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

sub carmichael_in_range ($A, $B, $k, $primes, $callback) {

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

                #~ my $valuation = valuation($p - 1, 2);
                #~ ($valuation > $k_exp and powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p)) || next;

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

            #~ my $valuation = valuation($p - 1, 2);
            #~ $valuation > $k_exp                                                    or next;
            #~ powmod($base, (($p - 1) >> $valuation) << $k_exp, $p) == ($congr % $p) or next;

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

open my $fh, '>>', 'carmichael_many_factors.txt';
$fh->autoflush(1);

my %upper_bounds = (
    36 => Math::GMPz->new("172830055680118494946407003033666507461304818401153193809383963715892256751681"),
    37 => Math::GMPz->new("804470457257926449746758080269993968890016257754008080494336091899208072210478721"),
    38 => Math::GMPz->new("244899124403114685817402147257255073631462537923865013235929258099059306044154477281"),
    39 => Math::GMPz->new("2912560918714425750692738781370955872381272347556033831319694306259522835520469570883201"),
    40 => Math::GMPz->new("27919230451074589715843311695264905349211077611052606444369590994069578293094749438742401"),
);

#foreach my $lambda (80000 .. 1e6) {
foreach my $lambda (sort {$a<=>$b} 15120, 30240, 110880, 285120, 332640, 498960, 604800, 1441440, 1663200, 1738800, 1814400, 2217600, 5216400, 13305600, 43243200, 64864800, 648648000, 4034016000, 8951342400, 12070749600, 67541947200) {
    #812700, 139230, 3197250, 4709250, 4709250, 2174130, 8824410, 20396250, 10442250, 982800, 7068600, 116953200, 88, 360, 3024, 12852, 8400, 39984, 18900, 486864, 529200) {
#while (<>) {
#    chomp(my $lambda = $_);

    #$lambda >= 96600 or next;

    say "# Generating: $lambda";

    my @primes = grep { $_ > 2 and $lambda % $_ != 0 and is_prime($_) } map { $_ + 1 } divisors($lambda);

    foreach my $k (36..40) {
        last if ($k > scalar(@primes));
        #if (binomial(scalar(@primes), $k) < 1e6) {
            carmichael_in_range(Math::GMPz->new(~0), $upper_bounds{$k}, $k, \@primes, sub ($n) { say $n; say $fh $n; });
        #}
    }
}
