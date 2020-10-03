#!/usr/bin/perl

# Prime-indexed primes q such that prime(q) + q + 1 and prime(q) - q - 1 are both prime-indexed primes.
# https://oeis.org/A318752

use 5.014;
use ntheory qw(is_prime nth_prime forprimes next_prime);

# New terms:
#   76232459, 83005829, 94265687, 125445101, 164054921, 165553511, 176691533, 199379657, 208672097, 228757709, 238916543, 240583781, 243132233, 243211679, 243443303, 243564509, 260234813

# 30 322305653
# 31 331268027
# 32 344089883
# 33 433795139
# 34 435806027
# 35 435908573
# 36 449928023
# 37 523987799
# 38 538980317
# 39 540024449
# 40 543944327
# 41 551642309
# 42 598534499
# 43 605750921
# 44 627077849
# 45 649003697
# 46 654136697
# 47 672927209
# 48 702395159
# 49 718915343
# 50 733639307
# 51 775344113
# 52 798099719
# 53 812649743
# 54 829685309
# 55 853990439
# 56 864734867
# 57 867110117
# 58
# 59
# 60
# 61
# 62
# 63
# 64
# 65


# Start from this term and search for next terms
my $from = 1839927611;

{
    my $prev_i;
    my $prev_p;

    sub after_prime1 {
        my ($n) = @_;

        if (not(defined($prev_i))) {

            $prev_i = $n;
            $prev_p = nth_prime($n);

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
    my $prev_i;
    my $prev_p;

    sub after_prime2 {
        my ($n) = @_;

        if (not(defined($prev_i))) {

            $prev_i = $n;
            $prev_p = nth_prime($n);

            return $prev_p;
        }

        for (1 .. $n - $prev_i) {
            $prev_p = next_prime($prev_p);
        }

        $prev_i = $n;
        return $prev_p;
    }
}

sub prime_count {
    my ($n) = @_;
    chomp(my $pi = `../primecount $n`);
    $pi;
}

forprimes {

    my $p = after_prime1($_);
    my $q = after_prime2($p);

    my $x = $q - $p - 1;
    my $y = $q + $p + 1;

    if (is_prime($x) and is_prime($y) and is_prime(prime_count($x)) and is_prime(prime_count($y))) {
        say $p;
    }

} prime_count($from), 1e10;
