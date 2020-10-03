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

my $N = 9;
my $P = nth_prime($N);
my $MAX = 323346556958041;

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

        #if (isok_b($n)) {
        if (isok_a($n)) {
            say $n;

            if ($n < $MAX) {
                $MAX = $n;
                say "New record: $n";
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
