#!/usr/bin/perl

# Generate primes that satisfy Pomerance's conditions for being factors of a PSW pseudoprime.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {
    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

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

my @smooth_primes;

foreach my $p (@{primes(307)}) {
    $p % 4 == 3 or next;
    push @smooth_primes, $p;
}

say "Smooth primes count: ", scalar(@smooth_primes);
say "Smooth primes: ", join(', ', @smooth_primes);

my $h = smooth_numbers((~0)>>2, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

#~ foreach my $n (@$h) {
    #~ my $t = 2*$n;

    #~ if ($t+2 < ~0 and is_prime($t+1) and is_smooth($t+2, 10000)) {

        #~ is_square_free(($t+2)>>2) || next;
        #~ next if not vecall { $_ % 4 == 3 } factor(($t+2)>>2);

        #~ say $t+1;
    #~ }
#~ }

foreach my $n (@$h) {
    my $t = 4*$n;

    if ($t < ~0 and is_prime($t-1) and is_smooth($t-2, 10000)) {

        is_square_free(($t-2)>>1) || next;
        next if not vecall { $_ % 4 == 1 } factor(($t-2)>>1);

        say $t-1;
    }
}
