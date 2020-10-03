#!/usr/bin/perl

# Prime(n), where n is such that (sum_{i=1..n} prime(i)) / n is an integer.
# https://oeis.org/A171399

use 5.014;
use Math::GMPz;
use ntheory qw(next_prime);

sub prime_count {
    my ($n) = @_;
    chomp(my $p = `../primecount $n`);
    return $p;
}

{
    my $prev_i;
    my $prev_p;

    sub nth_prime {
        my ($n) = @_;

        if (not(defined($prev_i))) {
            $prev_i = $n;
            chomp($prev_p = `../primecount -n $n`);
            return $prev_p;
        }

        for (1 .. $n - $prev_i) {
            $prev_p = next_prime($prev_p);
        }

        $prev_i = $n;
        return $prev_p;
    }
}

{
    my $prev_n;
    my $prev_sum;

    sub sum_primes {
        my ($n) = @_;

        if (not defined($prev_n)) {
            chomp(my $sum = `../primesum $n`);
            $prev_n   = $n;
            $prev_sum = Math::GMPz->new($sum);
            return $prev_sum;
        }

        $prev_sum += ntheory::sum_primes($prev_n + 1, $n);
        $prev_n = $n;

        return $prev_sum;
    }
}

for (my $n = prime_count("22128836547913") + 1 ; ; ++$n) {

    say "Testing: $n";

    my $p   = nth_prime($n);
    my $sum = sum_primes($p);

    if ($sum % $n == 0) {
        die "Found: $p with $sum % $n\n";
    }
}
