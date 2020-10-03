#!/usr/bin/perl

# Numbers with exactly five distinct exponents in their prime factorization, or five distinct parts in their prime signature.
# https://oeis.org/A323056

# Bellow 10^10
#~ Found prime p=631.
#~ Found 90397884 candidates.
#~ 2613

use 5.010;
use strict;
use warnings;

use List::Util qw(uniq);
use ntheory qw(primes factor_exp next_prime);

# Generate all the p-smooth numbers that are the product of <= 5 distinct primes bellow a given limit.

sub smooth_numbers {
    my ($limit, $primes) = @_;

    my @h = (1);
    foreach my $p (@$primes) {
        foreach my $n (@h) {
            if ($n * $p <= $limit and scalar(factor_exp($n * $p)) <= 5) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

# First, we find the smallest prime p such that:
#   p * 2^5 * 3^4 * 5^3 * 7^2 > limit

sub find_largest_prime {
    my ($limit) = @_;

    for (my $p = 2 ; ; $p = next_prime($p)) {
        if ($p * 2**5 * 3**4 * 5**3 * 7**2 > $limit) {
            return $p;
        }
    }
}

# For limit=10^9, we have p = 67

my $limit = 10**9;
my $p     = find_largest_prime($limit);

say "Found prime p=$p.";
my $h = smooth_numbers($limit, primes($p));
say "Found ", scalar(@$h), " candidates.";

foreach my $n (sort { $a <=> $b } @$h) {
    if (scalar(uniq(map { $_->[1] } factor_exp($n))) == 5) {
        print "$n, ";
    }
}

__END__
174636000, 206388000, 244490400, 261954000, 269892000, 274428000, 288943200, 291060000, 301644000, 309582000, 343980000, 349272000, 365148000, 366735600, 377848800, 383292000, 404838000, 411642000, 412776000, 422301600, 433414800, 449820000, 452466000, 457380000, 460404000, 488980800, 492156000, 502740000, 509652000, 511207200, 537878880, 539784000, 547722000, 548856000, 566773200, 570477600, 574938000, 577886400, 582120000, 587412000, 602316000, 603288000, 603741600, 608580000, 633452400, 638820000, 644565600, 650916000, 654885000, 655452000, 666468000, 674200800, 679140000, 682668000, 687960000, 689018400, 690606000, 698544000, 727650000, 730296000, 738234000, 744876000, 746172000, 751252320, 755697600, 764478000, 766584000, 766810800, 767340000, 773955000, 785862000, 802620000, 806818320, 818748000, 820260000, 822376800, 825552000, 841428000, 844603200, 845238240, 849420000, 859950000, 881118000, 881647200, 899640000, 901692000, 903474000, 905612400, 911282400, 914760000, 920808000, 928746000, 930852000, 936684000, 950796000, 955735200, 966848400, 968436000, 976374000, 977961600, 979020000, 983178000, 984312000, 985370400, 996559200, 999702000
