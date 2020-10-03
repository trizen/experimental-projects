#!/usr/bin/perl

# Generate Super-Poulet pseudoprimes to base 2, using prime factors bellow a certain limit.

use 5.020;
use warnings;
use experimental qw(signatures);

#use IO::Handle;
use List::Util qw(uniq);
use ntheory qw(:all);
use Math::Prime::Util::GMP;

sub super_poulet_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    forprimes {
        my $p = $_;

        #if ($p % 24 == 1 or $p % 24 == 13) {
       # if ($p % 24 == 1 or $p % 24 == 13) {
            my $z = znorder(2, $p);

          #  if (2*$z < $limit) {
            foreach my $d (divisors($p - 1)) {
                #if (powmod(2, $d, $p) == 1) {


                    if ($d % $z == 0) {

                        #if ($p > 1e8) {
                         #   if (exists $common_divisors{$d}) {
                          #      push @{$common_divisors{$d}}, $p;
                           # }
                        #}
                        #else {

                            #my $from = int($limit/$d);


                            #foreach my $k ($from .. $from + 100) {
                            #foreach my $k(map{$_->[0]**$_->[1]}factor_exp($p-1)) {

                            #if (exists($common_divisors{$d}) and scalar(@{$common_divisors{$d}}) >= 5) {

                    if (exists $common_divisors{$d}) {
                            foreach my $k (divisors($d)) {

                            #for (my $k = $from;
                            #foreach my $k (uniq(factor($p+1))) {

                        #foreach my $j (3..10) {
                                my $m = ($k + int rand 100);

                                if (($d % 2) * ($m % 2) != 0) {
                                    ++$m;
                                }

                                my $q = $d*$m+1;

                                #~ if (is_prime($q) and $d % znorder(2, $q) == 0) {
                                    #~ push @{$common_divisors{$d}}, $q;
                                #~ }

                                #if ((($q % 24 == 1) or ($q % 24 == 13)) and is_prime($q)) {
                                if (is_prime($q)) {
                                    my $z = znorder(2, $q);
                                    2*$z < $limit or next;
                                    foreach my $d(divisors($q-1)) {
                                        if ($d % $z == 0 and exists $common_divisors{$d}) {
                                            push @{$common_divisors{$d}}, $q;
                                        }
                                    }
                                }
                            }
                        }
                    #}
                    # }


                            push @{$common_divisors{$d}}, $p;
                        #}
                    }
           # }
            }
       # }
      #  }
    } 3, $limit;

    warn ":: Creating combinations...\n";

    #foreach my $arr (values %common_divisors) {
    while (my ($key, $arr) = each %common_divisors) {

        my $nf = 7;                 # minimum number of prime factors
        $arr = [uniq(@$arr)];
        #next if @$arr < $nf;

        my $l = scalar(@$arr);

        foreach my $k ($nf .. $l) {
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n);
            } $l, $k;
        }
    }
}

open my $fh, '>', 'super_poulet_numbers.txt';

#$fh->autoflush(1);

super_poulet_pseudoprimes(
    1e8,                            # limit of the largest prime factor
    sub ($n) {
        if ($n > ~0) {              # report only numbers greater than 2^64
            #warn "$n\n";
            say $fh $n;
        }
    }
);

close $fh;
