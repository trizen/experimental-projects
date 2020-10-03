#!/usr/bin/perl

use 5.014;
use warnings;

use HTTP::Tiny;
use List::Util qw(all);
use ntheory qw(is_prime is_carmichael);
use Math::AnyNum qw(:overload is_div prod);

# Download the b-file of A033502 added by Donovan Johnson
my $response = HTTP::Tiny->new->get('http://oeis.org/A033502/b033502.txt');

die "Failed to download the terms of A033502!\n" if not $response->{success};

my $content = $response->{content};
my @lines = split(/\n/, $content);

my @A033502;
foreach my $line (@lines) {

    $line =~ /\S/ or next;
    $line =~ /^#/ and next;

    my $n = Math::AnyNum->new((split(' ', $line))[1] // next);

    push @A033502, $n;
}

# Generate the factors of a Chernick number, given n
# and k, where k is the number of distinct prime factors.
sub chernick_carmichael_factors {
    my ($n, $k) = @_;

    (6 * $n + 1, 12 * $n + 1, (map { 2**$_ * 9 * $n + 1 } 1 .. $k - 2));
}

my @new_terms;
my $limit = $A033502[-1];

# Since each term in A033502 has 3 prime factors, we start with k=4 and generate all the
# terms that are smaller than the largest term of A033502 and have at least k prime factors.
for (my $k = 4 ; ; ++$k) {

    # We can stop the search when:
    #   (6*m + 1) * (12*m + 1) * Product_{i=1..k-2} (9 * 2^i * m + 1)
    # is greater than the largest term of A033502, for m=1.
    last if prod(chernick_carmichael_factors(1, $k)) > $limit;

    # Generate the extended Chernick numbers with k distinct prime factors,
    # that are also Carmichael numbers, bellow the limit we're looking for.
    for (my $n = 1 ; ; ++$n) {

        my @f = chernick_carmichael_factors($n, $k);
        my $c = prod(@f);

        last if $c > $limit;
        next if not is_carmichael($c);

        # Check the conditions for an extended Chernick Carmichael number
        next if not all { is_prime($_) } @f;
        next if not is_div(($f[0] - 1) / 6, 2**($k - 4));

        push @new_terms, $c;
    }
}

# Sort the terms
my @final_terms = sort { $a <=> $b } (@A033502, @new_terms);

# Display the terms
foreach my $k (0 .. $#final_terms) {
    say($k + 1, ' ', $final_terms[$k]);
}
