#!/usr/bin/perl

use 5.020;
use warnings;
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniqnum);
use File::Find qw(find);
use Math::GMPz;

# Let b(n) be the smallest odd composite k such that q^((k-1)/2) == -1 (mod k) for every prime q <= prime(n).

# b(1) = 3277
# b(2) = 1530787
# b(3) = 3697278427
# b(4) = 118670087467
# b(5) <= 2152302898747
# b(6) <= 614796634515444067
# b(7) <= 614796634515444067

# 341, 1729, 1729, 46657

my $N = 6;
my $P = nth_prime($N);
my $MAX = ~0;

my @primes_bellow = @{primes($P)};

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

sub isok_b {
    my ($k) = @_;

    #$k % 2 == 1 or return;

    vecall { powmod($_, ($k-1)>>1, $k) == $k-1 } @primes_bellow;
}

sub isok_b2 {
    my ($k) = @_;

    $k % 2 == 1 or return;

    vecall { powmod($_, ($k-1)>>1, $k) == 1 } 2..($P-1);
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

        #if ($n > $MAX or $n <= 2) {
         #   next;
        #}

        if ($n < ~0) {
            next;
        }

        if ($n > ~0) {
            $n = Math::GMPz->new("$n");
        }

        next if is_prime($n);
        next if $seen{$n}++;

        #if (isok_b($n)) {
        if (isok_b($n)) {

            say "Found: $n";

            #~ if ($n < $MAX) {
                #~ $MAX = $n;
                #~ say "New record: $n";
            #~ }
        }
    }

    close $fh;
}

my $psp = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/oeis-pseudoprimes";

find({
    wanted => sub {
        if ( /\.txt\z/) {
            #say "Processing $_";
            process_file($_);
        }
    },
    no_chdir => 1,
} =>  $psp);
