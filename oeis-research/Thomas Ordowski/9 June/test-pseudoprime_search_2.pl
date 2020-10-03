#!/usr/bin/perl

use 5.020;
use warnings;
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniqnum);
use File::Find qw(find);
use Math::GMPz;
use Math::AnyNum qw(prod);
use Math::Prime::Util::GMP qw(is_euler_pseudoprime);

sub is_absolute_euler_pseudoprime ($n) {
    is_carmichael($n) and vecall { (($n-1)>>1) % ($_-1) == 0 } factor($n);
}

my $N = 21;
my $P = nth_prime($N);
my $MAX = 10**300;

my @primes_bellow = @{primes($P)};

#~ my $n = 1;
#~ my $P = 2;

my @primes = (2);

sub non_residue {
    my ($n) = @_;

    foreach my $p (@primes) {
        sqrtmod($p, $n) // return $p;
    }

    return -1;
}

#~ foroddcomposites {
    #~ my $k = $_;

    #~ #if (powmod($q^((k-1)/2) == -1  and non_residue($k) == $P) {
    #~ if (powmod($P, ($k-1)>>1, $k) == $k-1) {
        #~ my $q = non_residue($k);

        #~ if ($q == $P) {
            #~ say $k;
            #~ $P = next_prime($P);
            #~ push @primes, $P;
            #~ exit if $P == 13;
        #~ }
    #~ }
#~ } 1e9;

#~ __END__

# Are there composite numbers n such that phi(n)2^(n-1) == -1 (mod n) ?


sub isok {
    my ($n) = @_;
    mulmod(divint(jordan_totient($n,2), jordan_totient($n, 1)), powmod(2, $n-1, $n), $n) == ($n-1);
}

local $| = 1;

#foreach my $n(1..1e9) {
foroddcomposites {
    if ( isok($_)) {
        print $_, ", ";
    }
} 1e9;

exit;

# Carmichael numbers of the form (6*k+1)*(12*k+1)*(18*k+1), where 6*k+1, 12*k+1 and 18*k+1 are all primes.
# Carmichael numbers of the form C = (30n-p)*(60n-(2p+1))*(90n-(3p+2)), where n is a natural number and p, 2p+1, 3p+2 are all three prime numbers.
# Numbers of the form: (6*m + 1) * (12*m + 1) * Product_{i=1..k-2} (9 * 2^i * m + 1), where k >= 3, with the condition that each of the factors is prime and that m is divisible by 2^(k-4).

#~ foreach my $k(1..1e7) {

    #~ my $x = 6*$k+1;
    #~ my $y = 12*$k + 1;
    #~ my $z = 18*$k+1;
    #~ #my $w = 9 * 2**2 * $k+1;

    #~ if (is_prime($x) and is_prime($y) and is_prime($z)

    #~ #and is_prime($w)

    #~ ) {
        #~ my $n = prod($x, $y, $z);

        #~ if (isok($n)) {
            #~ say "[$k] -> a($N) <= $n";
        #~ }
    #~ }
#~ }

#~ __END__
#~ #foreach my $k(1..1e6) {
#~ $| = 1;
#~ #for (my $k = 3; $k <= 1e9; $k += 2) {
#~ foroddcomposites {

    #~ my $k = $_;

    #~ #if (not is_prime($k) and isok($k)) {
    #~ if (isok($k)) {
        #~ print($k, ", ");

        #~ if (not isok_stronger($k)) {
            #~ die "Counter-example: $k";
        #~ }
    #~ }
#~ } 1e9;

#~ __END__

my %seen;

sub process_file {
    my ($file) = @_;

    open my $fh, '<', $file;
    while (<$fh>) {

        next if /^\h*#/;
        /\S/ or next;
        my $n = (split(' ', $_))[-1];

        $n || next;

        #if ($n > $MAX or $n <= 2) {
         #   next;
        #}

        if (length($n) > 30) {
            next;
        }

        #~ if ($n < 14469841 or $n > $MAX) {
            #~ next;
        #~ }

        #~ if ($n < ~0) {
            #~ next;
        #~ }

        #if ($n < 619440406020833) {
        #    next;
        #}

        #if ($n < 1.7 * 10**16) {
            #~ next;
        #~ }

        #~ if ($n > ~0) {
            #~ next;
        #~ }

        #~ if ($n > 10**8) {
            #~ next;
        #~ }

        #if ($n > ~0) {
        #if (length($n) > 30) {
        #    next;
        #}

        next if $seen{$n}++;

        if ($n > ~0) {
            $n = Math::GMPz->new("$n");
        }

        #next if is_prime($n);

        #if (isok_b($n)) {

      #  if (not is_absolute_euler_pseudoprime($n) and isok_12_may($n) ) {

    #  say "Testing: $n";

      #if (isok_12_may($n) and not is_carmichael($n)) {#not isok_12_may_stronger($n)) {
     # if (isok_12_may($n) and not isok_12_may_stronger($n)) {# not is_carmichael($n)) {

     if (isok($n)) {

            #say "Counter-example: $n";
            say "Found: $n";

            #~ if ($n < $MAX) {
                #~ $MAX = $n;
            #~ }

            #last if ($n > 15851273401);

            #$MAX = $n;

           # if (not isok_stronger($n)) {
           #     die "Counter-example: $n";
           # }

            #~ if ($n < $MAX) {
                #~ $MAX = $n;
                #~ say "New record: $n";
            #~ }
        }
    }

    close $fh;
}

my $psp = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/oeis-pseudoprimes";

find({
    wanted => sub {


        if (/\.txt\z/) {
            #say "Processing $_";
            process_file($_);
        }
    },
    no_chdir => 1,
} =>  $psp);
