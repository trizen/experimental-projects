#!/usr/bin/perl

# a(n) is the least Fermat pseudoprime k to base 2, such that the smallest quadratic non-residue of k is prime(n).
# a(n) is the least composite number k such that 2^(k-1) == 1 (mod k) and A020649(k) = prime(n).

# See also:
#   https://oeis.org/A020649
#   https://oeis.org/A307809

use 5.020;
use ntheory      qw(:all);
use experimental qw(signatures);

use Math::GMPz;
my @primes = @{primes(100)};

sub least_nonresidue_odd ($n) {    # for odd n

    my @factors = map { $_->[0] } factor_exp($n);

    foreach my $p (@primes) {
        (vecall { kronecker($p, $_) == 1 } @factors) || return $p;
    }

    return 101;
}

sub least_nonresidue_sqrtmod ($n) {    # for any n
    foreach my $p (@primes) {
        sqrtmod($p, $n) // return $p;
    }
    return 101;
}

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if length($n) > 25;
    is_pseudoprime($n, 2) || next;

    my $q = qnr($n);

    #next if ($q <= 43);     # 43 = prime(14)

    if (exists $table{$q}) {
        next if ($table{$q} <= $n);
    }

    $table{$q} = $n;
    printf("a(%2d) <= %s\n", prime_count($q), $n);
}

say "\nFinal results:";

foreach my $k (sort { $a <=> $b } keys %table) {
    my $n = prime_count($k);
    printf("a(%2d) <= %s\n", $n, $table{$k});
}

__END__
a( 1) = 341
a( 2) = 2047
a( 3) = 18721
a( 4) = 318361
a( 5) = 2163001
a( 6) = 17208601
a( 7) = 6147353521
a( 8) = 18441949681
a( 9) = 24155301361
a(10) = 2945030568769
a(11) = 22415236323481
a(12) = 6328140564467401
a(13) = 45669044917576081
a(14) = 111893049583818721

# Upper-bounds:

a(15) <= 3164607919507114081
a(16) <= 716074318521330199201
a(17) <= 129717501475261645009

# Upper-bounds with large Carmichael numbers:

a( 1) <= 19564907650561
a( 2) <= 264439982526721
a( 3) <= 275551466561281
a( 4) <= 2735858897856001
a( 5) <= 13281228027748801
a( 6) <= 47627546342246641
a( 7) <= 204205882154994721
a( 8) <= 683326283718141423361
a( 9) <= 112246826696602419341521
