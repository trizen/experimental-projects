#!/usr/bin/perl

# Smallest "non-residue" pseudoprime to base prime(n).
# https://oeis.org/A307809

# Interesting fact:
#   4398575137518327194521 is a Fermat pseudoprime for b in [2, 58].

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

my @primes = @{primes(100)};

sub least_nonresidue_odd ($n) {    # for odd n

    my @factors = map { $_->[0] } factor_exp($n);

    foreach my $p(@primes) {
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

    my $q = qnr($n);

    $n = Math::GMPz->new($n);

    if (exists $table{$q}) {
        next if ($table{$q} < $n);
    }

    if (powmod($q, ($n-1)>>1, $n) == $n-1) {
        $table{$q} = $n;
        my $k = prime_count($q);
        say "a($k) <= $n";
    }
}

say "\nFinal results:";

foreach my $k (sort { $a <=> $b } keys %table) {
    my $n = prime_count($k);
    printf("a(%2d) <= %s\n", $n, $table{$k});
}

__END__
a( 1) <= 3277
a( 2) <= 3281
a( 3) <= 121463
a( 4) <= 491209
a( 5) <= 11530801
a( 6) <= 512330281
a( 7) <= 15656266201
a( 8) <= 139309114031
a( 9) <= 7947339136801
a(10) <= 72054898434289
a(11) <= 334152420730129
a(12) <= 17676352761153241
a(13) <= 172138573277896681

# Very nice upper-bound:

a(14) <= 4398575137518327194521
