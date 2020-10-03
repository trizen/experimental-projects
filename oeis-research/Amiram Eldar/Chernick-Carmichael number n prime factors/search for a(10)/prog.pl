#!/usr/bin/perl

use 5.014;
use ntheory qw(:all);

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


my $n = 5;

foreach my $k(1..100) {

    my $m = pn_primorial($k);

    say "Testing: $m";

    my @primes = sieve_prime_cluster(6*$m , (1<<($n-2)) * 9*$m + 2,

        6*$m, 12*$m,

        map{ ((1<<$_) * 9 * $m ) }1..($n-2)

    );

    foreach my $p(@primes) {
        if (($p-1) % 6 == 0) {
            #say $p;
            if (is_chernick_carmichael($n, ($p-1)/6)) {

                my $t = vecprod(chernick_carmichael_factors($n, ($p-1)/6));

                if (is_carmichael($t)) {
                    say "Carmichael: $t";
                }
                elsif (is_pseudoprime($t, 2)) {
                    say "Fermat: ", $t;
                }
            }
        }
    }
}

__END__

#foreach my $n(1..10){

my $n = 7;
#foreach my $m(1..1000) {
#for (my $ = 1; ; ++$m) {

my $multiplier = 1<<($n-4);

my $k = 1;

while (1) {

    my $m = $k*$multiplier;

    my @primes = sieve_prime_cluster(6*$m + 1, (1<<($n-2)) * 9*$m + 1,
        map{ 6 * (  (1 << $_ ) * 3* $m) } 1..$n-2
    );

    #say for @primes;
    foreach my $p(@primes) {
        if (($p-1) % 6 == 0) {
            #say $p;
            if (is_chernick_carmichael($n, ($p-1)/6)) {
                say "Found: ", vecprod(chernick_carmichael_factors($n, ($p-1)/6));
            }
        }
    }

    ++$k;

   # $m = (1<<($n-2)) * 9*$m + 1;
}

#my $m = 950560;
#say 6*$m + 1;
#say ( (1<<($n-2)) * 9*$m + 1);
