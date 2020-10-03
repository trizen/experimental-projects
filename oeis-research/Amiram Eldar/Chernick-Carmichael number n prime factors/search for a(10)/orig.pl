#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 22 July 2018
# https://github.com/trizen

# Generate all the extended Chernick's Carmichael numbers bellow a certain limit.

# OEIS sequences:
#   https://oeis.org/A317126
#   https://oeis.org/A317136

# See also:
#   https://oeis.org/wiki/Carmichael_numbers
#   http://www.ams.org/journals/bull/1939-45-04/S0002-9904-1939-06953-X/home.html

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

# Generate the factors of a Chernick number, given n
# and m, where n is the number of distinct prime factors.
sub chernick_carmichael_factors ($n, $m) {
    (6*$m + 1, 12*$m + 1, (map { (1 << $_) * 9*$m + 1 } 1 .. $n-2));
}

# Check the conditions for an extended Chernick-Carmichael number
sub is_chernick_carmichael ($n, $m) {
    ($n == 2) ? (is_prime(6*$m + 1) && is_prime(12*$m + 1))
              : (is_prime((1 << ($n-2)) * 9*$m + 1) && __SUB__->($n-1, $m));
}

say vecprod(chernick_carmichael_factors(8, 977042880));

__END__

while (<DATA>) {
    my ($n, $m) = /\[(\d+), (\d+)\]/;

    foreach my $k(-1..5) {

    if (is_chernick_carmichael($n+$k, $m)) {
        my $t = vecprod(chernick_carmichael_factors($n+$k, $m));

        if (not is_carmichael($t)) {
            #die "error for [$n, $m, $k]";
            next;
        }

        say $t;
    }
}
}

exit;

my @terms;
my $limit = 0 + ($ARGV[0] // 10**50);

# Generate terms with k distict prime factors
for (my $n = 8 ; ; ++$n) {

    # We can stop the search when:
    #   (6*m + 1) * (12*m + 1) * Product_{i=1..n-2} (9 * 2^i * m + 1)
    # is greater than the limit, for m=1.
    #~ last if vecprod(chernick_carmichael_factors($n, 1)) > $limit;

    # Set the multiplier, based on the condition that `m` has to be divisible by 2^(k-4).
    my $multiplier = ($n > 4) ? 5*(1 << ($n-4)) : 1;

    # Generate the extended Chernick numbers with n distinct prime factors,
    # that are also Carmichael numbers, bellow the limit we're looking for.
    for (my $k = 1 ; ; ++$k) {

        my $m = $multiplier * $k;

        # All factors must be prime
        is_chernick_carmichael($n, $m) || next;

        say "Found: [$n, $m]";

        if ($n > 4 and $m % 5 != 0) {
            say "Counter-example for: [$n, $m]";
        }

        #~ exit if ($m == 532910560);

        # Get the prime factors
        #my @f = chernick_carmichael_factors($n, $m);

        # The product of these primes, gives a Carmichael number
        #my $c = vecprod(@f);
        #last if $c > $limit;
        #push @terms, $c;
    }
}

__END__
Found: [8, 950560]
Found: [8, 107675360]
Found: [8, 461417840]
Found: [8, 532910560]
Found: [8, 977042880]
Found: [8, 1411396800]
Found: [8, 1708622400]
Found: [8, 3738359200]
Found: [8, 5680753920]
Found: [8, 7533666800]
Found: [8, 8105474400]
Found: [8, 10072824720]
Found: [8, 13507401600]
Found: [8, 13692143920]
Found: [8, 16557166080]
Found: [8, 17265627920]
Found: [8, 20095081120]
Found: [8, 20157429040]
Found: [8, 20287336960]
Found: [8, 21965599040]
Found: [8, 22446071760]
Found: [8, 26262063520]
Found: [8, 28440427360]
Found: [8, 32222385680]
Found: [8, 32644863440]
Found: [8, 33765790240]
Found: [8, 35952282480]
Found: [8, 36584675920]
Found: [8, 36640979760]
Found: [8, 40120776080]
Found: [8, 40752538640]
Found: [8, 41391963760]
Found: [8, 44966320240]
Found: [8, 45309550400]
Found: [8, 46714920000]
Found: [8, 48020463920]
Found: [8, 49352568720]
Found: [8, 49457850400]
Found: [8, 50459253840]
Found: [8, 51286630880]
Found: [8, 51422560800]
Found: [8, 57468324480]
Found: [8, 58737657440]
Found: [8, 60160226240]
Found: [8, 60448468080]
Found: [8, 60918053840]
Found: [8, 62555045280]
Found: [8, 63113366960]
Found: [8, 65890692560]
Found: [8, 67324129600]
Found: [8, 68473583360]
Found: [8, 69131431600]
Found: [8, 75562470160]
Found: [8, 76867834960]
Found: [8, 77073929200]
Found: [8, 77326805040]
Found: [8, 79444077440]
Found: [8, 80483255120]
Found: [8, 80886029280]
Found: [8, 81906331920]
Found: [8, 83038210640]
Found: [8, 83552384400]
Found: [8, 83720196560]
Found: [8, 86639577600]
