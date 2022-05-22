#!/usr/bin/perl

# Numbers k such that F(k), F(k+1) and F(k+2) have the same binary weight (A000120), where F(k) is the k-th Fibonacci number (A000045).
# https://oeis.org/A353987

use 5.014;
use strict;
use warnings;

use Math::GMPz;

my $f1 = Math::GMPz::Rmpz_init_set_ui(0);
my $f2 = Math::GMPz::Rmpz_init_set_ui(1);
my $f3 = Math::GMPz::Rmpz_init_set_ui(1);

my @pop_counts;

push @pop_counts, Math::GMPz::Rmpz_popcount($f1);
push @pop_counts, Math::GMPz::Rmpz_popcount($f2);

foreach my $k (1..1e12) {

    Math::GMPz::Rmpz_add($f3, $f1, $f2);
    Math::GMPz::Rmpz_set($f1, $f2);
    Math::GMPz::Rmpz_set($f2, $f3);

    push @pop_counts, Math::GMPz::Rmpz_popcount($f3);

    if ($pop_counts[0] == $pop_counts[1] and $pop_counts[1] == $pop_counts[2]) {
        say "Found: ", $k-1;
    }

    shift @pop_counts;
}

__END__
Found: 1
Found: 51
Found: 130
Found: 996
Found: 3224
Found: 4287
Found: 9951
Found: 12676
Found: 72004
