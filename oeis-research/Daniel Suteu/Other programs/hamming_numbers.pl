#!/usr/bin/perl

# Generate the generalized Hamming numbers bellow a certain limit, given a set of primes.

use 5.020;
use warnings;
use Math::GMPz;
use experimental qw(signatures);
use ntheory qw(divisors vecsum primes divisor_sum valuation);

sub check_valuation($n, $p) {

    if ($p == 2) {
        return (valuation($n, 2) < 15);
    }

    if ($p == 3) {
        return ($n % ($p*$p*$p*$p*$p*$p) != 0);
    }

    if ($p == 5) {
        return ($n % ($p*$p*$p) != 0);
    }

    ($n % ($p*$p)) != 0;
}

sub hamming_numbers ($limit, $primes) {

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

# s(n) = my(d = divisors(n), s = vecsum(d) - d[#d]); forstep(i = #d-1, 1, -1, if(s <= 2*n, return(s == 2*n)); s-=d[i]); 0 \\ David A. Corneth, Feb 11 2019
sub isok {
    my ($n) = @_;

    $n = Math::GMPz->new($n);

    if (divisor_sum($n) < 2*$n) {
        return 0;
    }

    my @d = divisors($n);
    my $s = vecsum(@d) - pop(@d);

    while (@d) {

        if ($s <= 2*$n) {
            return $s == 2*$n;
        }

        $s -= pop(@d);
    }

    return 0;
}

my $h = hamming_numbers(10**15, primes(73));

say "Found: ", scalar(@$h), " terms";

foreach my $n(@$h) {

    if (isok($n)) {
        say $n;
    }

    #foreach my $k(0..30) {
    #    my $t = ($n * 2**$k);
     #   if (isok($t)) {
      #      say $t;
     #   }
    #}
}

__END__
foreach my $n(1..1e7) {
    if (isok($n)) {
        say $n;
    }
}

# Example: 5-smooth numbers bellow 100
#my $h = hamming_numbers(100, [2, 3, 5]);
#say join(', ', sort { $a <=> $b } @$h);
