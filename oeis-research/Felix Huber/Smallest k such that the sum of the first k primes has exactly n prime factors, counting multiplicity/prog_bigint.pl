#!/usr/bin/perl

# a(n) is the smallest k such that the sum of the first k primes has exactly n prime factors, counting multiplicity.
# https://oeis.org/A385997

# Known terms:
#   1, 3, 5, 9, 17, 11, 103, 119, 475, 237, 2661, 1481, 3045, 1567, 22019, 34907, 24995, 28173, 4915, 269225, 214183, 927571, 1085315, 9724983, 2567053, 4620383, 8827803, 38175467, 37167809, 98773463, 153124063, 257222427, 370283099, 24322477, 592786617

use 5.036;
use ntheory qw(forprimes);
use Math::Sidef qw();
use Math::GMPz;

# Sum for n = 36, exceeds 2**64

my $n   = 36;
my $k   = 1;
my $sum = Math::GMPz::Rmpz_init_set_ui(0);

$k = 1200000000;
$sum = Math::Sidef::prime_sum(ntheory::nth_prime($k));

say "Searching with n = $n";
say "Starting from k = $k with sum = $sum";

# Optimizations (black magic)
$n = Sidef::Types::Number::Number->new($n);
bless $sum, 'Sidef::Types::Number::Number';

forprimes {
    ++$k;
    Math::GMPz::Rmpz_add_ui($$sum, $$sum, $_);
    if ($sum->is_almost_prime($n)) {
        die "Found: a($n) = $k\n";
    }
    if ($k % 1e8 == 0) {
        say "Searching with k = $k";
    }
} ntheory::nth_prime($k+1), 1e13;

__END__
Searching with n = 36
Searching with k = 100000000
Searching with k = 200000000
Searching with k = 300000000
Searching with k = 400000000
Searching with k = 500000000
Searching with k = 600000000
Searching with k = 700000000
Searching with k = 800000000
Searching with k = 900000000
Searching with k = 1000000000
Searching with k = 1100000000
Searching with k = 1200000000
Parameter '1.84467440870467e+19' must be a non-negative integer at x.sf line 13.
