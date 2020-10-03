#!/usr/bin/perl

#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use Math::AnyNum qw(fibmod lucasmod);
use ntheory qw(is_prime powmod kronecker);

# Base-2 Fermat pseudoprimes:
#   http://www.cecm.sfu.ca/Pseudoprimes/index-2-to-64.html
#   http://www.cecm.sfu.ca/Pseudoprimes/psps-below-2-to-64.txt.bz2

foreach my $n (1 .. 3219781) {

    #is_fermat_fibonacci_prime($n) && do {warn "error: $n\n";
    #  last;
    #};

    my $eF  = 0;
    my $eL  = 0;
    my $mod = $n % 5;
    my $r   = $n - 2;

    if ($mod == 1 or $mod == 4) {
        $eF = 1;
        $eL = 1;
        $r  = 2;
    }
    elsif ($mod == 2 or $mod == 3) {
        $eF = -1;
        $eL = -1;
    }

    #if ($mod == 1) {
    #    $eL = $mod-5;
    #    $r = 11;
    #}

    #is_prime($n) || next;
    #say "[$mod] $n -> ", lucasmod($n-$e, $n);

    if (powmod(2, $n - 1, $n) == 1 and fibmod($n - $eF, $n) == 0) {
        my $t = fibmod($n, $n);

        $t == 1 or $t == $n - 1 or do {
            if (is_prime($n)) {
                warn "[#1] Missed prime: $n\n";
            }
            next;
        };

        if ($mod == 1) {

            #fibmod($n-1, $n+1) == 1 and do {
            lucasmod($n, $n) == 1 or do {

                if (is_prime($n)) {
                    warn "[#2] Missed prime: $n\n";
                }
                next;
            };
        }

        #say "First counter example: $n -> ", is_prime($n);
        if (not is_prime($n)) {
            say "Counter-example: $n -> ", $n % 5;
        }

        #sleep 1;
    }
    elsif (is_prime($n)) {
        say "Missed a prime: $n -> ", lucasmod($n - $eL, $n), ' -> ', $n % 5;
    }
}

__END__

my %seen;
my @nums;
while(<>) {
    next if /^\h*#/;
    /\S/ or next;
    my (undef, $n) = split(' ');

    $n || next;
    next if $seen{$n}++;

    #say $. if $. % 10000 == 0;

    #if ($n >= (~0 >> 1)) {
        $n = Math::GMPz->new("$n");
    #}

    #($n % 2 == 2) or ($n % 5 == 3) or next;

    push @nums, $n;

    #is_provable_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}

@nums = sort {$a <=> $b} @nums;

foreach my $n(@nums) {
    #is_fermat_fibonacci_prime($n) && do {warn "error: $n\n";
    #  last;
    #};

    my $e = 0;
    my $mod = $n%5;
      my $r = $n-2;

    if ($mod == 1 or $mod == 4) {
        $e = 1;
        $r = 2;
    }
    elsif ($mod == 2 or $mod == 3) {
        $e = -1;
    }

    #is_prime($n) || next;
    #say "[$mod] $n -> ", lucasmod($n-$e, $n);

    if (powmod(2, $n-1, $n) == 1 and lucasmod($n-$e, $n) == $r) {
        #say "First counter example: $n -> ", is_prime($n);
        if (not is_prime($n)) {
            say "Counter-example: $n";
            sleep 1;
        }
        #sleep 1;
    }
    elsif (is_prime($n)) {
        say "Missed a prime: $n";
    }
}
