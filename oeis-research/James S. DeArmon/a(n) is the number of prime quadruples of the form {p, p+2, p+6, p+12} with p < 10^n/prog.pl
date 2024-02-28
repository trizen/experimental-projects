#!/usr/bin/perl

# a(n) is the number of prime quadruples of the form {p, p+2, p+6, p+12} with p < 10^n.
# https://oeis.org/A370158

# Known terms:
#   0, 1, 4, 8, 24, 76, 313, 1644, 9397, 56734, 361386, 2417777

# New terms:
#   16785520,

use 5.022;
use ntheory ':all';
use bigint try => 'GMP';
use experimental qw(signatures);

sub a ($n, $from = 0) {
    my $count = () = sieve_prime_cluster($from, 10**$n, 2, 6, 12);
}

local $| = 1;

my $prev = 0;
my $from = 0;

for (0 .. 10) {
    my $count = a($_, $from) + $prev;
    print($count, ", ");
    $prev = $count;
    $from = 10**$_;
}

__END__

(Perl) use ntheory ':all'; use bigint; sub a { my $count = () = sieve_prime_cluster(1, 10**$_[0], 2, 6, 12) }; $| = 1; for (0..12) { print(a($_), ", ") } # ~~~~
