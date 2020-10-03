#!/usr/bin/perl

use 5.020;
use warnings;
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniqnum);
use File::Find qw(find);
use Math::GMPz;
use Math::AnyNum;
use Math::Prime::Util::GMP qw(is_euler_pseudoprime);

sub is_absolute_euler_pseudoprime ($n) {
    is_carmichael($n) and vecall { (($n-1)>>1) % ($_-1) == 0 } factor($n);
}

# Let b(n) be the smallest odd composite k such that q^((k-1)/2) == -1 (mod k) for every prime q <= prime(n).

# b(1) = 3277
# b(2) = 1530787
# b(3) = 3697278427
# b(4) = 118670087467
# b(5) <= 2152302898747
# b(6) <= 614796634515444067
# b(7) <= 614796634515444067

# 341, 1729, 1729, 46657

my $N = 13;
my $P = nth_prime($N);
my $MAX = ~0;

my @primes_bellow = @{primes($P)};

#~ my $n = 1;
#~ my $P = 2;

my @primes = (2);

sub non_residue {
    my ($n) = @_;

    foreach my $p (@primes) {

        #if ($p > $P) {
        #    return -1;
        #}

        #sqrtmod($p, $n) // return $p;

        #sqrtmod($p, $n) // do { say "$p $n"; return $p};
        #kronecker($n, $p) == 1 and return $p;

        (vecall { kronecker($p, $_->[0]) == 1 } factor_exp($n)) || return $p;
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

sub isok {
    my ($k) = @_;

    if (powmod($P, ($k-1)>>1, $k) == $k-1)  {
        my $q = non_residue($k);
        return ($P == $q);
    }

    return;

    #~ my $res;
    #~ my $p = nth_prime($n);

    #~ for(my $k = $A000229[$n-1]*$A000229[$n-1]; ; $k+=2) {

        #~ if (!is_prime($k) and powmod($p, ($k-1)>>1, $k) == $k-1) {
            #~ my $q = non_residue($k, $p);

            #~ if ($p == $q) {
                #~ return $k;
            #~ }
        #~ }
    #~ }

    #~ return $res;
}

#~ Found: 2095988771234401
#~ Found: 35488761020833
#~ Found: 4364724604902481
#~ Found: 5087540155980241
#~ Found: 619440406020833

sub isok_12_may {
    my ($k) = @_;

    # Odd composite numbers n such that b^((n-1)/2) == +-1 (mod n) for every natural b < log(n).

   my $w = $k-1;
   my $z = $w>>1;

   my $upto =  logint($k, 4); #int(log("$k"));

   #~ if (lc($upto) eq 'inf') {
       #~ $upto = Math::AnyNum->new($k)->ilog;
   #~ }

    #for (my $p = 2; $p <= $upto; ++$p) {

    for(my $p = 2; $p <= $upto; $p = next_prime($p)) {
        my $t = powmod($p, $z, $k);
        ($t == 1) || ($t == $w) || return;
    }

    return 1;
}

#~ say isok_12_may(35488761020833);
#~ say isok_12_may(2095988771234401);
#~ say is_absolute_euler_pseudoprime(35488761020833);

# Counter-examples to log_4(n)
# Counter-example: 8072818294413421
# Counter-example: 63542085102541
# Counter-example: 2593071578729521
# Counter-example: 3825123056546413051
# Counter-example: 318665857834031151167461
# Counter-example: 3317044064679887385961981
# Counter-example: 32446040579997661
# Counter-example: 1567766946934843021
# Counter-example: 2243715650874353701
# Counter-example: 495032720098981681

#~ __END__
sub isok_12_may_stronger {
    my ($k) = @_;

    # Odd composite numbers n such that b^((n-1)/2) == +-1 (mod n) for every natural b < log(n).

   my $w = $k-1;
   my $z = $w>>1;

   my $upto = logint($k, 4); #int(log("$k"));

   #~ if (lc($upto) eq 'inf') {
       #~ $upto = Math::AnyNum->new($k)->ilog;
   #~ }

    for(my $p = 2; $p <= $upto; ++$p) {
        my $t = powmod($p, $z, $k);
        ($t == 1) || return;
    }

    return 1;
}

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

sub isok_b {
    my ($k) = @_;

    #$k % 2 == 1 or return;

    vecall { powmod($_, ($k-1)>>1, $k) == $k-1 } @primes_bellow;
}

sub isok_b2 {
    my ($k) = @_;

    $k % 2 == 1 or return;

    vecall { powmod($_, ($k-1)>>1, $k) == 1 } 2..($P-1);
}

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

        #~ if (length($n) > 30) {
            #~ next;
        #~ }

        if ($n < 10**16) {
            next;
        }

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
      if (isok_12_may($n) and not isok_12_may_stronger($n)) {# not is_carmichael($n)) {

            #say "Counter-example: $n";
            say $n;

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
        if ( /\.txt\z/) {
            #say "Processing $_";
            process_file($_);
        }
    },
    no_chdir => 1,
} =>  $psp);
