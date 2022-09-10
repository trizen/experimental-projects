#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

# PARI/GP program (in range):
#   carmichael(A, B, k) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, u=0, v=0) = my(list=List()); if(k==1, forprime(p=u, v, my(t=m*p); if((t-1)%l == 0 && (t-1)%(p-1) == 0, listput(list, t))), forprime(q = p, sqrtnint(B\m, k), my(t = m*q); my(L=lcm(l, q-1)); if(gcd(L, t) == 1, my(u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, u, v)))))); list); vecsort(Vec(f(1, 1, 3, k)));

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = $x/$y;
    ($q*$y == $x) ? $q : ($q+1);
}

sub is_pomerance_prime ($p) {

    # p == 3 (mod 8) and (5/p) = -1
    # is_congruent(p, 3, 8) && (kronecker(5, p) == -1) &&

    # (p-1)/2 and (p+1)/4 are squarefree
    # is_squarefree((p-1)/2) && is_squarefree((p+1)/4) &&

    # all factors q of (p-1)/2 are q == 1 (mod 4)
    # factor((p-1)/2).all { |q|
    #     is_congruent(q, 1, 4)
    # } &&

    # all factors q of (p+1)/4 are q == 3 (mod 4)
    # factor((p+1)/4).all {|q|
    #    is_congruent(q, 3, 4)
    # }

    # p == 3 (mod 8)
    $p%8 == 3 or return;

    # (5/p) = -1
    #kronecker(5, $p) == -1 or return;

    # (p-1)/2 and (p+1)/4 are squarefree
    (is_square_free(($p-1)>>1) and is_square_free(($p+1)>>2)) || return;

    # all prime factors q of (p-1)/2 are q == 1 (mod 4)
    (vecall {  $_%4 == 1 } factor(($p-1)>>1)) || return;

    # all prime factors q of (p+1)/4 are q == 3 (mod 4)
    (vecall {  $_%4 == 3 } factor(($p+1)>>2)) || return;

    return 1;
}

#my $prime_file = '../primes/smooth_primes.txt';
my $prime_file = '../primes/nice_primes.txt';
my @prime_list;

open my $fh, '<', $prime_file
    or die "Can't open file <<$prime_file>> for reading: $!";

while (<$fh>) {
    chomp(my $p = $_);
    if ($p > ~0) {
        $p = Math::GMPz->new("$p");
    }

    is_smooth($p-1, 1000) || next;
    is_smooth($p+1, 1000) || next;

    if (is_pomerance_prime($p)) {
        push @prime_list, $p;
    }
}

close $fh;

say "# The prime list has ", scalar(@prime_list), " terms";

sub carmichael_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k+1)>>1);

    sub ($m, $lambda, $lambda2, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            say "# Prime $p -> $m -- ($lambda, $lambda2)";

            foreach my $p (@prime_list) {

                $p < $u and next;
                $p > $v and last;

                my $t = $m*$p;
                if (($t-1)%$lambda == 0 and ($t-1)%($p-1) == 0) {
                    say "Carmichael: $t";
                    if (($t+1)%$lambda == 0 and ($t+1)%($p+1) == 0) {
                        die "Found a Williams number: $t";
                        $callback->($t);
                    }
                }
            }

            return;
        }

        my $y = rootint(divint($B, $m), $k);
        my $x = $p;

        foreach my $p (@prime_list) {

            $p < $x and next;
            $p > $y and last;

            #is_pomerance_prime($p) || next;

            #is_smooth($p+1, 1000) || next;
            #is_smooth($p-1, 1000) || next;

            my $L = lcm($lambda, $p-1);
            gcd($L, $m) == 1 or next;

            my $L2 = lcm($lambda2, $p+1);
            gcd($L2, $m) == 1 or next;

            $L < ~0 or next;
            $L2 < ~0 or next;

            #say "# Prime: $p -> $m";

            # gcd($m*$p, euler_phi($m*$p)) == 1 or die "$m*$p: not cyclic";

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = $B / $t;

            if ($u <= $v) {
                my $r = next_prime($p);
                __SUB__->($t, $L, $L2, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }

    }->(Math::GMPz->new(1), 1, 1, 3, $k);
}

my $k = 5;
my $from = Math::GMPz->new(2)**64;
my $upto = Math::GMPz->new(10)**20000;

#while (1) {

    say "# [$k] Sieving: [$from, $upto]";

    carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });

 #   $from = $upto+1;
 #   $upto = 2*$from;
#}
