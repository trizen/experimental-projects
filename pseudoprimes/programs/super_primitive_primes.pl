#!/usr/bin/perl

# Least prime p such that the n smallest primitive roots modulo p are the first n primes.
# https://oeis.org/A355016

# Known terms:
#    3, 5, 53, 173, 2083, 188323, 350443, 350443, 1014787, 29861203, 154363267

# Try to find an upper-bound for a(12), by generating primes of the form k*p + 1, where k is small and p is prime.

# No upper-bound for a(12) is currently known.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $n      = 12;
my @primes = @{primes(nth_prime($n))};

sub isok ($p) {
    foreach my $q (@primes) {
        is_primitive_root($q, $p)
          or return;
    }
    foreach my $c (4 .. $primes[-1] - 1) {
        is_prime($c) && next;
        is_primitive_root($c, $p)
          and return;
    }
    return 1;
}

my $p_min     = 1e9;
my $p_max_len = 60;

my %seen;

while (my ($n, $value) = each %db) {

    my @factors = split(' ', $value);

    $factors[-1] > $p_min or next;

    foreach my $p (@factors) {

        $p > $p_min             or next;
        length($p) < $p_max_len or next;

        #next if $seen{$p}++;

        say "Checking: $p";

        if (isok($p)) {
            die "Found upper-bound: a($n) <= $p\n";
        }
    }
}

dbmclose(%db);

say "No upper-bound found...";
