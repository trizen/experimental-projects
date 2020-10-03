#!/usr/bin/perl

# Positions of records in A306440.
# https://oeis.org/A307221

# Where A306440(n) is defined as:
#   Number of different ways of expressing 2*n as (p - 1)*(q - 1), where p < q are primes

use 5.014;
use ntheory qw(:all);

# The next term might be: 275675400 (later confirmed by Giovanni Resta).

sub numbers {
    my ($n) = @_;

    #say "N -> $n";

    my $count = 0;
    #my $max = sqrtint($n);

    foreach my $d(divisors($n)) {
        #last if ($d >= $max);
        $d < $n/$d or last;
        if (is_prime($d+1) and is_prime(($n/$d)+1)) {
            #say "$d, ",  $n/$d, ' -> ', $d * ($n/$d);
            ++$count;
        }
    }

    $count;
}

foreach my $n(8648640, 19656000, 19958400, 21205800, 43243200, 46781280, 57657600, 64864800, 122522400, 151351200) {
    say "a($n) = ", numbers(2*$n);
}

#say numbers(8648640 * 2);
# 8648640, 19656000, 19958400, 21205800, 43243200, 46781280, 57657600, 64864800, 122522400, 151351200

$| = 1;
my $max = 49;

foreach my $n(1e8..1e8+1e8) {       # takes forever

    my $t = numbers(2*$n);

    if ($t > $max) {
        $max = $t;
        print $n, ", ";
    }
}

#say join(', ', map{ numbers(2*$_) } 1..95);

__END__
# a(18) = 627699239
# a(19) = 880021141
# a(20) = 1001124539
# a(21) = 1041287603
# a(22) = 1104903617
# a(23) = 1592658611
# a(24) = 1717999139

# Extra:
# a(25) = 8843679683
# a(26) =

my $from = 12027699239;  # incremented

# From: 11027699239 -- To: 12027699239

say "From: $from -- To: ", $from+1e9;

forsemiprimes {

   if (powmod(2, $_+1, $_) == 1) {
        say "Found: $_";
   }

} $from, $from + 1e9;

# 15, 35, 119, 5543, 74447, 90859, 110767, 222179, 389993, 1526849, 2927297, 3626699, 4559939, 24017531, 137051711, 160832099, 229731743, 627699239, 880021141, 1001124539, 1041287603, 1104903617, 1592658611, 1717999139
