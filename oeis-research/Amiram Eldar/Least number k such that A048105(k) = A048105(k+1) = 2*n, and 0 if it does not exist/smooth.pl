#!/usr/bin/perl

# a(n) is the least number k such that A048105(k) = A048105(k+1) = 2*n, and 0 if it does not exist.
# https://oeis.org/A344315

# Known terms:
#   1, 27, 135, 2511, 2295, 6975, 5264, 12393728, 12375, 2200933376, 108224, 257499, 170624

# The sequence continues with ?, 4402431, ?, 126224, 41680575, 701443071, 46977524, 1245375, 2707370000, 4388175, 3129761024, 1890944. a(13) and a(15) > 4*10^10, if they exist. (Amiram Eldar)

# Upper-bounds:
#   a(13) <= 3684603215871
#   a(15) <= 2035980763136
#   a(25) <= 1965640805422351777791
#   a(26) <= 3127059999

# Some larger upper-bounds:
#   a(13) <= 23742854217728
#   a(26) <= 1350757416697856
#   a(26) <= 6085737708051120128
#   a(26) <= 176974592054955188682752

# a(13) and a(15) were confirmed by Martin Ehrenstein (May 20 2021).

# In general, a(n) <= A215199(n+1). Proof: tau(p*q^n) = (1+1)*(n+1), 2^omega(p*q^n) = 2^2, tau(p*q^n) - 2^omega(p*q^n) = 2*(n-1).

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 30;
    }

    if ($p == 3) {
        return valuation($n, $p) < 30;
    }

    if ($p == 5) {
        return valuation($n, $p) < 5;
    }

    if ($p == 7) {
        return valuation($n, $p) < 4;
    }

    if ($p == 11) {
        return valuation($n, $p) < 2;
    }

    if ($p == 13) {
        return valuation($n, $p) < 2;
    }

    if ($p == 17) {
        return valuation($n, $p) < 2;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p) and nu($n * $p) <= 60) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub nu ($n) {
    divisors($n) - (1 << prime_omega($n));
}

sub a ($n) {
    for (my $k = 1 ; ; ++$k) {
        if (nu($k) == 2 * $n and 2 * $n == nu($k + 1)) {
            return $k;
        }
    }
}

my $h = smooth_numbers(~0, primes(40));

say "\nFound: ", scalar(@$h), " terms";

my %table;

my @primes = (1, @{primes(20, 1e3)});

foreach my $v (@$h) {

    foreach my $p (@primes) {
        my $n = mulint($v, $p);

        my $k_a = nu($n);
        my $k_b = nu($n + 1);

        my $k_x = nu($n - 1);
        my $k_y = $k_a;

        my $isok = 0;
        my $p    = 0;

        if ($k_a % 2 == 0 and $k_a == $k_b) {
            $isok = 1;
            $p    = $k_a / 2;
        }

        if ($k_x % 2 == 0 and $k_x == $k_y) {
            $isok = 1;
            $p    = $k_x / 2;
            $n -= 1;
        }

        if ($isok) {
            if (not exists($table{$p}) or $n < $table{$p}) {
                $table{$p} = $n;
                say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
            }
        }
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", $table{$k};
}

__END__
a(1) <= 27
a(2) <= 135
a(3) <= 2511
a(4) <= 2295
a(5) <= 6975
a(6) <= 5264
a(7) <= 12393728
a(8) <= 12375
a(9) <= 2200933376
a(10) <= 108224
a(11) <= 257499
a(12) <= 170624
a(13) <= 3684603215871
a(14) <= 4402431
a(15) <= 2035980763136
a(16) <= 126224
a(17) <= 41680575
a(18) <= 701443071
a(19) <= 46977524
a(20) <= 1245375
a(21) <= 2707370000
a(22) <= 4388175
a(23) <= 3129761024
a(24) <= 1890944
a(25) <= 1965640805422351777791
a(26) <= 3127059999
a(28) <= 10029824
a(29) <= 3966616575
a(30) <= 4879092701575970815
a(31) <= 738265239999
a(32) <= 11889800
a(34) <= 13466816
a(35) <= 5476095078399
a(36) <= 6917295104
a(37) <= 7958235824
a(38) <= 788112324
a(40) <= 37590399
a(41) <= 2757807614395425024
a(42) <= 5616839375
a(44) <= 49727600
a(46) <= 243309824
a(48) <= 139701375
a(50) <= 1071045980790624
a(52) <= 262490624
a(55) <= 3093890624
a(56) <= 233741024
a(58) <= 39931827200
a(59) <= 3637514062109375
a(60) <= 4454993031892762624
a(62) <= 767982359375
a(64) <= 285112575
a(67) <= 8076578339375
a(68) <= 1444313024
a(70) <= 24414101401599
a(72) <= 2510949375
a(74) <= 8945585775
a(76) <= 17245475324
a(80) <= 3326997375
a(82) <= 288778010624
a(84) <= 40623419375
a(88) <= 1921172175
a(92) <= 5306271200
a(96) <= 5071197375
a(104) <= 133064229375
a(112) <= 53048097024
a(128) <= 20910176000
a(160) <= 183643260800
