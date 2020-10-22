#!/usr/bin/perl

# a(n) is the first k such that n = Omega(k) = Omega(k-1) + Omega(k+1), or 0 if there is no such k, where Omega is A001222.
# https://oeis.org/A338302

# New terms found:

# a(17) = 8044724224
# a(18) = 39790739456
# a(19) = 53730279424

use 5.014;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);

sub f($n) {

    my $found = 0;
    foralmostprimes {

        if (prime_bigomega($_-1) + prime_bigomega($_+1) == $n) {
            $found = $_;
            lastfor;
        }

    } $n, 1, 1e12;

    return $found;
}

my $count = 1;
foreach my $n(1..20) {
    say "a($count) = ", f($n);
    ++$count;
}

__END__
a(1) = 2
a(2) = 4
a(3) = 8
a(4) = 56
a(5) = 80
a(6) = 624
a(7) = 1216
a(8) = 8576
a(9) = 66176
a(10) = 59049
a(11) = 386560
a(12) = 1476225
a(13) = 7354880
a(14) = 58989951
a(15) = 70184960
a(16) = 36315136
