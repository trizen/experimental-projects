#!/usr/bin/perl

use 5.020;
use warnings;
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniqnum);
use File::Find qw(find);
use Math::GMPz;

# a(5) <= 5113747913401
# a(6) <= 30990302851201

#~ a(5) <= 32203213602841
#~ a(6) <= 323346556958041
#~ a(7) <= 2528509579568281
#~ a(8) <= 5189206896360728641
#~ a(9) <= 12155831039329417441

#~ c(1) = 341
#~ c(2) = 83333
#~ c(3) = 12322133
#~ c(4) <= 11408333333
#~ c(5) <= 31093792133
#~ c(6) <= 6974740163333
#~ c(7) <= 50256612851482133
#~ c(8) <= 62362204244003333
#~ c(9) <= 2603789657124456533
#~ c(10) <= 2603789657124456533

# a(n) = 561, 1729, 1729, 399001, 399001, 1857241, 1857241, 6189121, 14469841, 14469841, 14469841,

# New terms (Solovay-Strassen bounds):
# a(12) <= 86566959361
# a(13) <= 311963097601
# a(14) <= 369838909441
# a(15) <= 6389476833601
# a(16) <= 6389476833601
# a(17) <= 1606205228509922041
# a(18) <= 1606205228509922041
# a(19) <= 1606205228509922041
# a(20) <= 1606205228509922041

my $N = 21;
my $P = nth_prime($N);
my $MAX = 10**100;

# a(5) <= 5113747913401
# a(6) <= 30990302851201
# a(7) <=

my @primes_bellow = @{primes($P-1)};

my @primes = @{primes(100)};

sub non_residue {
    my ($n) = @_;

    foreach my $p (@primes) {

        if ($p > $P) {
            return -1;
        }

        sqrtmod($p, $n) // return $p;
    }

    return -1;
}


sub isok_a {
    my ($k) = @_;

    if (powmod($P, ($k-1)>>1, $k) == $k-1)  {
        return vecall { powmod($_, ($k-1)>>1, $k) == 1 } 2..($P-1);
    }

    return;
}

sub isok_b {
    my ($k) = @_;

    if (powmod($P, ($k-1)>>1, $k) == 1)  {
        return vecall { powmod($_, ($k-1)>>1, $k) == $k-1 } @primes_bellow;
    }

    return;
}

sub isok_c {
    my ($k) = @_;

    # let c(n) be the smallest odd composite number k > 1 such that p^((k-1)/2) == -(p/k) (mod k) for every prime p <= prime(n), where (p/k) is the Jacobi symbol,

   # if (powmod($P, ($k-1)>>1, $k) == 1)  {

   ($k > 1) || return;
   ($k % 2 == 1) || return;

        return vecall {
            powmod($_, ($k-1)>>1, $k) == ((kronecker($_, $k)) % $k)
        } 1..$P;
  #  }
#
  #  return;
}

#~ foreach my $k(2..1e9) {

    #~ $k %2 == 1 or next;
    #~ next if is_prime($k);

    #~ if (isok_c($k)) {
        #~ say "a($N) = $k";
        #~ ++$N;
        #~ $P = nth_prime($N);
        #~ @primes_bellow = @{primes($P)};
    #~ }
#~ }

#~ __END__

my %seen;

sub process_file {
    my ($file) = @_;

    open my $fh, '<', $file;
    while (<$fh>) {

        next if /^\h*#/;
        /\S/ or next;
        my $n = (split(' ', $_))[-1];

        $n || next;

        if ($n > $MAX) {
            next;
        }

        if ($n > ~0) {
            $n = Math::GMPz->new("$n");
        }

        next if is_prime($n);
        next if $seen{$n}++;

        if (isok_c($n)) {
            say "a($N) <= $n";

            if ($n < $MAX) {
                $MAX = $n;
                say "New record: a($N) <= $n";
            }
        }
    }
}

my $psp = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/oeis-pseudoprimes";

find({
    wanted => sub {
        if ( /\.txt\z/) {
            process_file($_);
        }
    },
    no_chdir => 1,
} =>  $psp);
