#!/usr/bin/perl

# a(n) is the least semiprime that is the first of n consecutive semiprimes s(1) ... s(n) such that s(i) - prime(i) are all equal.
# https://oeis.org/A367075

# Known terms:
#   4, 9, 118, 514, 1202, 9662, 46418, 198878, 273386, 717818, 717818, 270893786

# New terms:
#   a(13) = 1009201118
#   a(14) = 1009201118
#   a(15) = 68668578806

use 5.036;
use ntheory qw(:all);

my $n          = 0;
my @primes     = (2);
my @semiprimes = (4);

forsemiprimes {

    my $d = $semiprimes[0] - 2;

    if ($semiprimes[-1] - $primes[-1] == $d and vecall { $semiprimes[$_] - $primes[$_] == $d } 0 .. $#primes) {
        ++$n;
        say "a($n) = ", $semiprimes[0];
        push @primes, next_prime($primes[-1] // 1);
    }
    elsif (scalar(@semiprimes) > $n) {
        shift @semiprimes;
    }

    push @semiprimes, $_;
} 5, 1e12;

__END__
# Sidef code to verify terms:

func isok(n,k) {
    semiprimes(k, nth_semiprime(k.semiprime_count + n - 1)).map_kv{|k,v| v - prime(k+1) }.uniq.len == 1
}

say isok(12, 270893786)     #=> true
say isok(13, 1009201118)    #=> true
say isok(14, 1009201118)    #=> true
say isok(15, 1009201118)    #=> false
say isok(15, 68668578806)   #=> true
say isok(16, 68668578806)   #=> false

__END__
a(1) = 4
a(2) = 9
a(3) = 118
a(4) = 514
a(5) = 1202
a(6) = 9662
a(7) = 46418
a(8) = 198878
a(9) = 273386
a(10) = 717818
a(11) = 717818
a(12) = 270893786
a(13) = 1009201118
a(14) = 1009201118
a(15) = 68668578806
^C
perl prog.pl  4367.35s user 99.20s system 99% cpu 1:14:59.08 total
