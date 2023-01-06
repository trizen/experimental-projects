#!/usr/bin/perl

# a(n) is the first emirp p that starts a sequence of n emirps x(1),...,x(n) with x(1) = p and x(k+1) = 2*x(k) - reverse(x(k)), but 2*x(n) - reverse(x(n)) is not an emirp.
# https://oeis.org/A358983

# Known terms:
#   13, 941, 1471, 120511, 368631127

# If it exists:
#   a(6) > 1000568933891

use 5.020;
use warnings;
use ntheory qw(:all);

my @seen;

#my $p = 70000000033;
#my $q = 80000000033;

my $p = 1000568933891;
my $q = 2000000000003;

#my $p = next_prime(300000000);
#my $q = next_prime(400000000);

#my $p = 13;
#my $q = 23;

while (1) {

    say "Sieving: ($p, $q)";

    forprimes {

        if (is_prime(scalar(reverse($_))) and $_ ne reverse($_)) {

            my $q = 2*$_ - reverse($_);

            my $count = 1;
            while (is_prime($q) and is_prime(scalar(reverse($q))) and $q ne reverse($q)) {
                $q = 2*$q - reverse($q);
                ++$count;
            }

            if (not $seen[$count]) {
                say "a($count) <= $_";
                $seen[$count] = 1;
            }
        }
    } $p, $q;

    my $c = substr($q, 0, 1);

    if ($c == 2) {
        $p = next_prime('3' . ('0' x (length($q)-1)));
        $q = next_prime('4' . ('0' x (length($q)-1)));
    }
    elsif ($c == 4 or $c == 5 or $c == 6) {
        $p = next_prime('7' . ('0' x (length($q)-1)));
        $q = next_prime('8' . ('0' x (length($q)-1)));
    }
    elsif ($c == 8) {
        $p = next_prime('9' . ('0' x (length($q)-1)));
        $q = next_prime('1' . ('0' x (length($q))));
    }
    else {
        $p = $q;
        $q = next_prime(($c+1) . ('0' x (length($q)-1)));
    }
}

__END__
a(1) = 13
a(2) = 941
a(3) = 1471
a(4) = 120511
a(5) = 368631127
