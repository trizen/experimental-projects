#!/usr/bin/perl

use 5.014;
use Math::GMPz;
use ntheory qw(next_prime forprimes);

# Prime(n), where n is such that (sum_{i=1..n} prime(i)) / n is an integer.
# https://oeis.org/A171399

# Known terms:
#   2, 83, 241, 6599, 126551, 1544479, 4864121, 60686737, 1966194317, 63481708607, 1161468891953, 14674403807731, 22128836547913

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

my $n = 803058000000;                            # next term is greater than prime($n)
#my $n = prime_count(22128836547913)-1e7;
#my $n = 10;

#my $n = prime_count(22128836547913) + 1;
#my $n = 758792000000;                           # next term is greater than prime($n)

#my $n = prime_count(14674403807731)-1e7;

my $p   = nth_prime($n);
my $sum = sum_primes($p - 1);

forprimes {

    #$sum += $_;
    Math::GMPz::Rmpz_add_ui($sum, $sum, $_);

    if ($n % 1000000 == 0) {
        say "Testing: $n";
    }

    #if ($sum % $n == 0) {
    if (Math::GMPz::Rmpz_divisible_ui_p($sum, $n)) {
        die "Found: $_ with $sum % $n\n";
    }

    ++$n;
} $p, 10**15;
