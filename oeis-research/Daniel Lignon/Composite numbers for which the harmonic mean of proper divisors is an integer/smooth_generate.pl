#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# These are composite numbers n such that sigma(n)-1 divides n*(tau(n)-1).

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    1

      #~ if ($p == 2) {
      #~ return valuation($n, $p) < 5;
      #~ }

      #~ if ($p == 3) {
      #~ return valuation($n, $p) < 3;
      #~ }

      #~ if ($p == 7) {
      #~ return valuation($n, $p) < 3;
      #~ }

      #~ ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub isok ($m) {
    modint(mulint($m, divisor_sum($m, 0) - 1), divisor_sum($m) - 1) == 0;
}

my $h = smooth_numbers(1e13, primes(20));

say "\nTotal: ", scalar(@$h), " terms\n";

my %table;

foreach my $n (@$h) {

    #$n > 1e7 || next;

    my $p = divisor_sum($n) - 1;

    is_prime($p) || next;
    my $m = mulint($n, $p);

    if (isok($m)) {
        say "Found: $n -> $m";
    }
}

__END__

Found: 35 -> 1645
Found: 231 -> 88473
Found: 171366 -> 63626653506
Found: 3662109375 -> 22351741783447265625
