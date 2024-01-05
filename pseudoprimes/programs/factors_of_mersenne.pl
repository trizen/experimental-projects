#!/usr/bin/perl

# Try to find factors of a Mersenne number.

use 5.036;
use Math::GMPz;
use ntheory                qw(forprimes foroddcomposites);
use Math::Prime::Util::GMP qw(:all);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $n = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);
    $factors[-1] < ~0 and next;

    Math::Prime::Util::GMP::is_pseudoprime($key, 2) || next;

    foreach my $f (@factors) {
        if ($f > ~0 and length($f) < 70) {
            my $order = znorder(2, $f);
            if ($order > 1e6 and $order < 1e9 and is_prime($order)) {
                #say "M$order has a factor: $f";
                say "2^$order - 1 = $f"
            }
        }
    }
}
